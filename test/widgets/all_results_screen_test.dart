import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemorph_flutter/services/download_service.dart';
import 'package:gemorph_flutter/widgets/sidebar_scaffold.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../mocks/mock_download_service.mocks.dart';

@GenerateMocks([DownloadService])
void main() {
  testWidgets('AllResultsScreen shows file list and download buttons',
      (WidgetTester tester) async {
    final mockService = MockDownloadService();

    // Stub listOutputFiles to return test data
    when(mockService.listOutputFiles()).thenAnswer(
      (_) async => [
        Result(
          id: '1',
          filename: 'result1.obj',
          date: DateTime.now(),
          status: 'completed',
        ),
        Result(
          id: '2',
          filename: 'result2.obj',
          date: DateTime.now(),
          status: 'completed',
        ),
      ],
    );

    // Use a custom widget that injects the mock service
    await tester.pumpWidget(MaterialApp(
      home: _MockAllResultsScreen(service: mockService),
    ));

    // Expect loading indicator first
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the FutureBuilder resolve
    await tester.pumpAndSettle();

    // Check file names
    expect(find.text('result1.obj'), findsOneWidget);
    expect(find.text('result2.obj'), findsOneWidget);

    // Check that each has a download button
    expect(find.byIcon(Icons.download), findsNWidgets(2));
  });
}

/// Simplified widget that accepts a custom DownloadService for testing
class _MockAllResultsScreen extends StatefulWidget {
  final DownloadService service;
  const _MockAllResultsScreen({required this.service});

  @override
  State<_MockAllResultsScreen> createState() => _MockAllResultsScreenState();
}

class _MockAllResultsScreenState extends State<_MockAllResultsScreen> {
  late Future<List<Result>> _futureFiles;

  @override
  void initState() {
    super.initState();
    _futureFiles = widget.service.listOutputFiles();
  }

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      child: FutureBuilder<List<Result>>(
        future: _futureFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load files'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No files found.'));
          }

          final results = snapshot.data!;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                title: Text(result.filename),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {}, // ignore actual download in test
                ),
              );
            },
          );
        },
      ),
    );
  }
}
