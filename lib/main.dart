import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gemorph_flutter/config/app_config.dart';
import 'package:gemorph_flutter/screens/face_model_screen.dart';
import 'package:gemorph_flutter/screens/report_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'screens/upload_dna_screen.dart';
import 'screens/all_results_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/contact_us_screen.dart';
import 'screens/about_us_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  doWhenWindowReady(() {
    // full screen
    appWindow.maximize();
    appWindow.minSize = const Size(830, 660);
    appWindow.show();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // 🔥 Add a function to call backend
  Future<void> testBackend() async {
    try {
      var url = Uri.parse(AppConfig.baseUrl); // FastAPI URL
      var response = await http.get(url);
      print('Backend Response: ${response.body}');
    } catch (e) {
      print('Error connecting to backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call backend test when app starts
    testBackend(); // <--- call here

    return MaterialApp(
      title: 'GeMorph',
      theme: ThemeData(
        primaryColor: AppTheme.primaryBackground,
        scaffoldBackgroundColor: AppTheme.primaryBackground,
      ),
      initialRoute: '/home',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/home':
            page = const HomeScreen();
            break;
          case '/upload':
            page = const UploadDNAScreen();
            break;
          case '/reports':
            page = const ReportsScreen();
            break;
          case '/reports-details':
            final args = settings.arguments as Map<String, dynamic>;
            final reportId = args['reportId'] as String;

            page = ReportDetailScreen(
              reportId: reportId,
            );
            break;
          case '/reports-model-view':
            final args = settings.arguments as Map<String, dynamic>;
            final reportId = args['reportId'] as String;
            final filename = args['filename'] as String;

            page = FaceModelScreen(reportId: reportId, filename: filename);
            break;
          case '/downloads':
            page = const AllResultsScreen();
            break;
          case '/about':
            page = const AboutUsScreen();
            break;
          case '/contacts':
            page = const ContactUsScreen();
            break;
          default:
            page = const HomeScreen();
        }

        // Return PageRouteBuilder with no animation
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Page (Coming Soon)')),
    );
  }
}
