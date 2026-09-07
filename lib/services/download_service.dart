import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:gemorph_flutter/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Result {
  final String id;
  final String filename;
  final DateTime date;
  final String status;

  Result({
    required this.id,
    required this.filename,
    required this.date,
    required this.status,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json['id'] as String,
        filename: json['filename'] as String,
        date: DateTime.parse(json['date'] as String),
        status: json['status'] as String,
      );
}

class DownloadService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<List<Result>> listOutputFiles() async {
    final uri = Uri.parse('$_baseUrl/downloads');
    final r = await http.get(uri);

    if (r.statusCode != 200) {
      throw Exception('Failed to list output files: ${r.statusCode}');
    }

    final List body = json.decode(r.body) as List;
    return body.map((j) => Result.fromJson(j)).toList().reversed.toList();
  }

  // Download the zip file and extract it to a temporary directory donot return anything
  Future<void> downloadAndExtract3dModel(String fileId) async {
    final uri = Uri.parse('$_baseUrl/obj/$fileId/download');
    final r = await http.get(uri);

    if (r.statusCode != 200) {
      throw Exception('Failed to download 3D model: ${r.statusCode}');
    }

    // Decode the zip archive
    final zipFile = r.bodyBytes;
    final archive = ZipDecoder().decodeBytes(zipFile);

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final outputDir = Directory('${tempDir.path}/3d_model/');

    // Ensure directory exists
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    // Clear old files
    await for (final entity in outputDir.list()) {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await entity.delete(recursive: true);
      }
    }

    // Extract new files
    for (final file in archive) {
      final filename = '${outputDir.path}/${file.name}';
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(filename);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        await Directory(filename).create(recursive: true);
      }
    }
  }

  Future<void> delete3dModelFolder() async {
    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final modelDir = Directory('${tempDir.path}/3d_model/');

    // Clear old files
    await for (final entity in modelDir.list()) {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await entity.delete(recursive: true);
      }
    }
  }
}
