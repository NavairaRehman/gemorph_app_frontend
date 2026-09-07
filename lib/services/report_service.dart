// lib/services/report_service.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:gemorph_flutter/config/app_config.dart';
import 'package:http/http.dart' as http;
// if you use DateFormat elsewhere
// if you use PDF generation here

class ReportProgress {
  final String status;
  final String step;

  ReportProgress({
    required this.status,
    required this.step,
  });
}

class Report {
  final String id;
  final String filename;
  final DateTime date;
  final String status;
  final Map<String, dynamic>? predictions;

  Report({
    required this.id,
    required this.filename,
    required this.date,
    required this.status,
    this.predictions,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'] as String,
        filename: json['filename'] as String,
        date: DateTime.parse(json['date'] as String),
        status: json['status'] as String,
        predictions: json['predictions'] != null
            ? json['predictions'] as Map<String, dynamic>
            : null,
      );
}

class ReportService {
  static const _baseUrl = AppConfig.baseUrl;

  /// **NEW**: allow injecting a custom http.Client (for tests)
  final http.Client _client;
  ReportService({http.Client? client}) : _client = client ?? http.Client();

  /// 1) Uploads the DNA file, returns the generated report_id
  Future<String> uploadDNA(Uint8List bytes, String filename) async {
    final uri = Uri.parse('$_baseUrl/upload_dna/');
    final req = http.MultipartRequest('POST', uri)
      ..files
          .add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    // Use injected client for sending
    final streamed = await _client.send(req);
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 202) {
      throw Exception('Upload failed: ${resp.statusCode}: ${resp.body}');
    }
    final Map body = json.decode(resp.body);
    return body['file_id'] as String;
  }

  /// 2) Polls the status endpoint until it reports "completed"
  Stream<ReportProgress> waitForCompletion(String fileId,
      {Duration pollInterval = const Duration(seconds: 10),
      int maxTries = 60}) async* {
    final uri = Uri.parse('$_baseUrl/reports/$fileId/status');
    for (var i = 0; i < maxTries; i++) {
      final r = await _client.get(uri);

      if (r.statusCode == 200) {
        final jsonBody = json.decode(r.body);
        final status = jsonBody['status'] as String;
        final step = jsonBody['progress'] as String;

        yield ReportProgress(
          status: status,
          step: step,
        );

        if (status.toLowerCase() == 'completed') return;

        if (status.toLowerCase() == 'failed') {
          throw Exception('Processing failed on server');
        }
      }
      await Future.delayed(pollInterval);
    }
    throw Exception('Timed out waiting for report to complete');
  }

  /// 3) Fetches the actual report JSON
  Future<Report> getReport(String fileId) async {
    final uri = Uri.parse('$_baseUrl/reports/$fileId');
    final r = await _client.get(uri);
    if (r.statusCode != 200) {
      throw Exception('Failed to fetch report: ${r.statusCode}');
    }
    return Report.fromJson(json.decode(r.body));
  }

  /// 4) Returns the download URL for the PDF
  Uri pdfUrl(String fileId) => Uri.parse('$_baseUrl/reports/$fileId/download');

  /// 5) Fetches the list of all reports
  Future<List<Report>> listReports() async {
    final uri = Uri.parse('$_baseUrl/reports');
    final r = await _client.get(uri);
    if (r.statusCode != 200) {
      throw Exception('Failed to list reports: ${r.statusCode}');
    }
    final List body = json.decode(r.body) as List;
    return body.map((j) => Report.fromJson(j)).toList();
  }

  /// 6) Optional fallback if getReport fails
  Future<Report> getReportOrEmpty(String fileId) async {
    try {
      return await getReport(fileId);
    } catch (_) {
      // return an “empty” Report instead of throwing
      return Report(
        id: '',
        filename: '',
        date: DateTime.now(),
        status: 'Unknown',
        predictions: {},
      );
    }
  }

  /// 7) Full PDF fetch and save (instead of launching URL)
  Future<Uint8List> downloadPdfBytes(String fileId) async {
    final uri = Uri.parse('$_baseUrl/reports/$fileId/download');
    final r = await _client.get(uri);
    if (r.statusCode != 200) {
      throw Exception('PDF download failed: ${r.statusCode}');
    }
    return r.bodyBytes;
  }
}

// class ReportService {
//   static final List<Report> _reports = [];

//   Future<Report> generateDummyReport({
//     required String filename,
//     required Uint8List fileBytes,
//   }) async {
//     final newReport = Report(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       filename: filename,
//       date: DateTime.now(),
//       status: 'Completed',
//       predictions: _generateDummyPredictions(filename),
//     );

//     _reports.add(newReport);
//     return newReport;
//   }

//   Map<String, dynamic> _generateDummyPredictions(filename) {
//     final baseName = p.basenameWithoutExtension(filename);
//     if (baseName == 'test_dna1') {
//       return {
//         'features': [
//           {'feature': 'Eye Color', 'prediction': 'Brown', 'score': 0.96},
//           {'feature': 'Hair Color', 'prediction': 'Brown', 'score': 0.84},
//           {'feature': 'Skin Tone', 'prediction': 'Fair', 'score': 0.73},
//           {'feature': 'Ancestry', 'prediction': 'European', 'score': 0.81},
//           {'feature': 'Gender', 'prediction': 'Female', 'score': 0.99},
//         ],
//         'face_model_accuracy': 0.89,
//       };
//     }
//     else if (baseName == 'input_file') {
//       return {
//         'features': [
//           {'feature': 'Eye Color', 'prediction': 'Blue', 'score': 0.95},
//           {'feature': 'Hair Color', 'prediction': 'Blonde', 'score': 0.88},
//           {'feature': 'Skin Tone', 'prediction': 'White', 'score': 0.79},
//           {'feature': 'Ancestry', 'prediction': 'European', 'score': 0.91},
//           {'feature': 'Gender', 'prediction': 'Male', 'score': 0.99},
//         ],
//         'face_model_accuracy': 0.91,
//       };
//     }
//     else {
//       return {
//         'features': [
//           {'feature': 'Eye Color', 'prediction': 'Brown', 'score': 0.86},
//           {'feature': 'Hair Color', 'prediction': 'Dark Brown', 'score': 0.79},
//           {'feature': 'Skin Tone', 'prediction': 'Medium', 'score': 0.73},
//           {'feature': 'Ancestry', 'prediction': 'European', 'score': 0.83},
//           {'feature': 'Gender', 'prediction': 'Male', 'score': 0.99},
//         ],
//         'face_model_accuracy': 0.89,
//       };
//     }
//   }

//   Future<Uint8List> generatePdf(Report report) async {
//     final pdf = pw.Document();

//     // 1. Compute the asset path
//     final baseName = p.basenameWithoutExtension(report.filename);
//     final assetPath = 'assets/images/$baseName.png';

//     // 2. Load image bytes from the bundle
//     Uint8List? imageBytes;
//     try {
//       final data = await rootBundle.load(assetPath);
//       imageBytes = data.buffer.asUint8List();
//     } catch (e) {
//       // asset not found; leave imageBytes null
//     }

//     // 3. Build your page
//     pdf.addPage(
//       pw.Page(
//         build: (context) {
//           final children = <pw.Widget>[
//             pw.Header(level: 0, text: 'DNA Analysis Report'),
//             pw.Paragraph(text: 'Report ID: ${report.id}'),
//             pw.Paragraph(
//               text: 'Date: ${DateFormat.yMd().add_Hms().format(report.date)}'
//             ),
//             pw.Paragraph(text: 'Filename: ${report.filename}'),
//           ];

//           // If we loaded the image, insert it
//           if (imageBytes != null) {
//             children.addAll([
//               pw.SizedBox(height: 20),
//               pw.Center(
//                 child: pw.Image(
//                   pw.MemoryImage(imageBytes),
//                   width: 200, // or whatever fits your layout
//                   fit: pw.BoxFit.contain,
//                 ),
//               ),
//             ]);
//           }

//           // Then the predictions table
//           children.addAll([
//             pw.Header(level: 1, text: 'Predictions'),
//             pw.Table.fromTextArray(
//               headers: ['Feature', 'Prediction', 'Confidence'],
//               data: report.predictions['features']
//                   .map<List<String>>((f) => [
//                         f['feature'].toString(),
//                         f['prediction'].toString(),
//                         '${((f['score'] as double) * 100).toStringAsFixed(1)}%',
//                       ])
//                   .toList(),
//             ),
//           ]);

//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: children,
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   List<Report> getReports() => _reports.reversed.toList();

//   Report? getReport(String id) => _reports.firstWhere(
//     (r) => r.id == id,
//     orElse: () => Report(
//       id: '',
//       filename: '',
//       date: DateTime.now(),
//       status: 'Unknown',
//       predictions: {},
//     ),
//   );
// }

// class Report {
//   final String id;
//   final String filename;
//   final DateTime date;
//   final String status;
//   final Map<String, dynamic> predictions;

//   Report({
//     required this.id,
//     required this.filename,
//     required this.date,
//     required this.status,
//     required this.predictions,
//   });
// }
