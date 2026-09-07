import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemorph_flutter/widgets/sidebar_scaffold.dart'; // Adjust based on actual location
import 'package:gemorph_flutter/screens/upload_dna_screen.dart'; // Adjust for correct imports

void main() {
  testWidgets('SidebarScaffold widget test', (WidgetTester tester) async {
    // Build SidebarScaffold with a simple child widget for testing
    await tester.pumpWidget(
      MaterialApp(
        home: SidebarScaffold(
          child: Container(),
        ),
      ),
    );

    // Verify that the AppBar displays the 'GeMorph' title
    expect(find.text('GeMorph'), findsOneWidget);

    // Verify that the drawer is present
    final drawerButton = find.byTooltip('Open navigation menu');
    expect(drawerButton, findsOneWidget);

    // Open the drawer
    await tester.tap(drawerButton);
    await tester.pumpAndSettle();

    // Verify that the drawer items are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Upload DNA'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);

    // Tap on 'Upload DNA' item in the drawer
    await tester.tap(find.text('Upload DNA'));
    await tester.pumpAndSettle();

    // Verify if UploadDNAScreen is pushed onto the navigator
    expect(find.byType(UploadDNAScreen), findsOneWidget);
  });
}
