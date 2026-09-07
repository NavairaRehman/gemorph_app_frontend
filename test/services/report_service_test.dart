// test/services/report_service_test.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gemorph_flutter/services/report_service.dart';

void main() {
  group('ReportService', () {
    test('uploadDNA returns file ID on 202 response', () async {
      // Arrange: mock client returns 202 with a JSON body containing file_id
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, equals('/upload_dna/'));
        return http.Response(jsonEncode({'file_id': 'abc123'}), 202);
      });
      final service = ReportService(client: mockClient);

      // Act
      final fileId = await service.uploadDNA(Uint8List(0), 'test.vcf');

      // Assert
      expect(fileId, equals('abc123'));
    });

    test('uploadDNA throws on non-202 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });
      final service = ReportService(client: mockClient);

      expect(
        () => service.uploadDNA(Uint8List(0), 'test.vcf'),
        throwsA(isA<Exception>()),
      );
    });

    test('getReport returns Report on 200', () async {
      final nowIso = DateTime.now().toIso8601String();
      final mockPayload = {
        'id': 'r1',
        'filename': 'file.vcf',
        'date': nowIso,
        'status': 'completed',
        'predictions': {
          'Eye Color': ['Brown', '64.17%']
        }
      };
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, equals('/reports/r1'));
        return http.Response(jsonEncode(mockPayload), 200);
      });
      final service = ReportService(client: mockClient);

      final report = await service.getReport('r1');

      expect(report.id, equals('r1'));
      expect(report.filename, equals('file.vcf'));
      expect(report.date.toIso8601String(), equals(nowIso));
      expect(report.status, equals('completed'));
      expect(report.predictions!['Eye Color']![0], equals('Brown'));
    });

    test('getReport throws on non-200', () async {
      final mockClient =
          MockClient((_) async => http.Response('Not Found', 404));
      final service = ReportService(client: mockClient);

      expect(
        () => service.getReport('r1'),
        throwsA(isA<Exception>()),
      );
    });

    test('waitForCompletion returns when status becomes completed', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        final status = callCount++ < 1 ? 'processing' : 'completed';
        return http.Response(
            jsonEncode({'status': status, 'progress': 'Step $callCount'}), 200);
      });
      final service = ReportService(client: mockClient);

      // Should complete without throwing
      final stream = service.waitForCompletion('r1',
          pollInterval: const Duration(milliseconds: 1), maxTries: 3);
      await for (final progress in stream) {
        expect(progress.status, isIn(['processing', 'completed']));
        if (progress.status == 'completed') break;
      }
    });

    test('waitForCompletion throws on failure status', () async {
      final mockClient = MockClient((_) async => http.Response(
          jsonEncode({'status': 'failed', 'progress': 'Failed step'}), 200));
      final service = ReportService(client: mockClient);

      expect(
        () async {
          final stream = service.waitForCompletion('r1',
              pollInterval: const Duration(milliseconds: 1), maxTries: 1);
          await for (final _ in stream) {
            // Should throw before yielding any values
          }
        },
        throwsA(isA<Exception>()),
      );
    });

    test('listReports returns list of Report', () async {
      final nowIso = DateTime.now().toIso8601String();
      final payload = [
        {
          'id': 'r1',
          'filename': 'a.vcf',
          'date': nowIso,
          'status': 'completed',
          'predictions': {}
        },
        {
          'id': 'r2',
          'filename': 'b.vcf',
          'date': nowIso,
          'status': 'processing',
          'predictions': {}
        }
      ];
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, equals('/reports'));
        return http.Response(jsonEncode(payload), 200);
      });
      final service = ReportService(client: mockClient);

      final list = await service.listReports();
      expect(list.length, equals(2));
      expect(list[0].id, equals('r1'));
      expect(list[1].status, equals('processing'));
    });

    test('listReports throws on non-200', () async {
      final mockClient = MockClient((_) async => http.Response('Err', 500));
      final service = ReportService(client: mockClient);

      expect(
        () => service.listReports(),
        throwsA(isA<Exception>()),
      );
    });

    test('downloadPdfBytes returns bytes on 200', () async {
      final pdfData = Uint8List.fromList([1, 2, 3]);
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, equals('/reports/r1/download'));
        return http.Response.bytes(pdfData, 200);
      });
      final service = ReportService(client: mockClient);

      final bytes = await service.downloadPdfBytes('r1');
      expect(bytes, equals(pdfData));
    });

    test('downloadPdfBytes throws on non-200', () async {
      final mockClient = MockClient((_) async => http.Response('Err', 404));
      final service = ReportService(client: mockClient);

      expect(
        () => service.downloadPdfBytes('r1'),
        throwsA(isA<Exception>()),
      );
    });

    test('getReportOrEmpty returns fallback when getReport fails', () async {
      final mockClient = MockClient((_) async => http.Response('Err', 500));
      final service = ReportService(client: mockClient);

      final fallback = await service.getReportOrEmpty('r1');
      expect(fallback.id, isEmpty);
      expect(fallback.status, equals('Unknown'));
    });
  });
}
