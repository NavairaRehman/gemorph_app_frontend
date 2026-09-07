import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemorph_flutter/screens/upload_dna_screen.dart';
import 'package:gemorph_flutter/services/report_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ReportService])
void main() {
  setUp(() {
    // Setup can be added here if needed for future tests
  });

  Future<void> pumpUploadScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UploadDNAScreen(),
      ),
    );
    await tester.pump(); // Let widgets build
  }

  testWidgets('UploadDNAScreen shows basic UI elements', (tester) async {
    await pumpUploadScreen(tester);

    // Title
    expect(find.text('Upload DNA data'), findsOneWidget);

    // Drag & Drop or Tap
    expect(find.textContaining('Drag & Drop'), findsOneWidget);

    // Submit Button
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('Tapping submit with no file shows error snackbar',
      (tester) async {
    await pumpUploadScreen(tester);

    // Tap the Submit button
    await tester.tap(find.text('Submit'));
    await tester.pump(); // Pump to show snackbar

    // Verify snackbar
    expect(find.text('Please select a file first.'), findsOneWidget);
  });

  // You can expand this by mocking _uploadFile, etc.
}
