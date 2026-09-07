import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gemorph_flutter/config/app_config.dart';
import 'package:gemorph_flutter/services/download_service.dart';
import 'package:gemorph_flutter/services/report_service.dart';
import 'package:gemorph_flutter/theme/app_theme.dart';
import 'package:gemorph_flutter/widgets/sidebar_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  // Constants
  static const double imageWidth = 300.0;
  static const Map<String, String> ancestryMap = {
    "European": "Europe",
    "African": "Africa",
    "Asian": "Asia",
    "North American": "North-America",
    "South American": "South-America",
    "Australian": "Australia",
  };

  late Future<Report?> _reportFuture;
  final ReportService _reportService = ReportService();
  final DownloadService _downloadService = DownloadService();
  bool _isGlbButtonEnabled = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _reportFuture = _reportService.getReport(widget.reportId);
    if (kIsWeb) {
      _isGlbButtonEnabled = true;
    } else {
      _download3dModel(); // Desktop workflow: download and extract OBJ assets.
    }
  }

  Future<void> _download3dModel() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      await _downloadService.downloadAndExtract3dModel(widget.reportId);
      if (mounted) {
        setState(() {
          _isGlbButtonEnabled = true;
          _isDownloading = false;
        });
      }
    } catch (e) {
      print('Error downloading 3D model: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to prepare 3D model: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, String>> _predictions(Map<String, dynamic>? predictionsMap) {
    if (predictionsMap == null) return [];

    List<Map<String, String>> predictions = [];

    for (var key in predictionsMap.keys) {
      final value = predictionsMap[key];
      if (value is List && value.length >= 2) {
        predictions.add({
          "feature": key,
          "prediction": value[0]?.toString() ?? 'Unknown',
          "confidence": value[1]?.toString() ?? '0%',
        });
      }
    }

    return predictions;
  }

  String _formatDate(DateTime date) {
    return DateFormat("MMMM dd, yyyy | HH:mm:ss 'UTC'").format(date);
  }

  Widget _buildRuntimeImage(String id, double width) {
    final url = '${AppConfig.baseUrl}/static/images/$id.png';
    return Image.network(
      url,
      width: width,
      fit: BoxFit.contain,
      loadingBuilder: (c, child, progress) =>
          progress == null ? child : const CircularProgressIndicator(),
      errorBuilder: (c, _, __) => const Text('Image not available'),
    );
  }

  String _getAncestryPrediction(Map<String, dynamic>? predictions) {
    if (predictions == null) return "European";

    final ancestryData = predictions["Ancestry"];
    if (ancestryData is List && ancestryData.isNotEmpty) {
      return ancestryData[0]?.toString() ?? "European";
    }

    return "European"; // Default fallback
  }

  Widget _buildRuntimeMap(String ancestry, double width) {
    final mapName = ancestryMap[ancestry] ?? 'Europe'; // Default fallback
    final url = '${AppConfig.baseUrl}/static/maps/$mapName.png';
    return Image.network(
      url,
      width: width,
      fit: BoxFit.contain,
      loadingBuilder: (c, child, progress) =>
          progress == null ? child : const CircularProgressIndicator(),
      errorBuilder: (c, _, __) => const Text('Image not available'),
    );
  }

  Future<void> _downloadPdf(String fileId) async {
    const baseUrl = AppConfig.baseUrl;
    final url = Uri.parse('$baseUrl/reports/$fileId/download');

    try {
      if (kIsWeb) {
        await launchUrl(url, webOnlyWindowName: '_blank');
      } else if (Platform.isWindows) {
        await Process.run('start', [url.toString()], runInShell: true);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url, $e')),
        );
      }
    }
  }

  Widget _buildPredictionsTable(List<Map<String, String>> predictions) {
    bool isMediumScreen = MediaQuery.of(context).size.width < 1500;
    bool isSmallScreen = MediaQuery.of(context).size.width < 1200;
    return Container(
      alignment: Alignment.center,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerTheme: const DividerThemeData(
            color: Colors.transparent,
          ),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all<Color>(
            AppTheme.primaryBlue,
          ),
          headingRowHeight: 35,
          dataRowColor: WidgetStateProperty.all<Color>(
            const Color(0xFF262626),
          ),
          dataRowMinHeight: 35,
          dataRowMaxHeight: 35,
          dividerThickness: 0,
          showBottomBorder: false,
          columnSpacing: 0,
          horizontalMargin: 0,
          headingTextStyle: AppTheme.montserrat(
            color: AppTheme.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          columns: [
            DataColumn(
              columnWidth: FixedColumnWidth(isSmallScreen
                  ? 200
                  : isMediumScreen
                      ? 280
                      : 350),
              headingRowAlignment: MainAxisAlignment.center,
              label: const Text('Feature'),
            ),
            DataColumn(
              columnWidth: FixedColumnWidth(isSmallScreen
                  ? 200
                  : isMediumScreen
                      ? 280
                      : 350),
              headingRowAlignment: MainAxisAlignment.center,
              label: const Text('Prediction'),
            ),
            DataColumn(
              columnWidth: FixedColumnWidth(isSmallScreen
                  ? 200
                  : isMediumScreen
                      ? 280
                      : 350),
              headingRowAlignment: MainAxisAlignment.center,
              label: const Text('Confidence'),
            ),
          ],
          rows: predictions.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> prediction = entry.value;
            return DataRow(
              cells: [
                DataCell(_buildTableCell(prediction['feature'] ?? "", index)),
                DataCell(
                    _buildTableCell(prediction['prediction'] ?? "", index)),
                DataCell(
                    _buildTableCell(prediction['confidence'] ?? "", index)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, int index) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: index > 0
            ? Border.all(
                color: AppTheme.border,
                width: 0.5,
              )
            : const Border(
                right: BorderSide(
                  color: AppTheme.border,
                  width: 0.5,
                ),
                left: BorderSide(
                  color: AppTheme.border,
                  width: 0.5,
                ),
                bottom: BorderSide(
                  color: AppTheme.border,
                  width: 0.5,
                ),
              ),
      ),
      child: Text(
        text,
        style: AppTheme.montserrat(
          color: AppTheme.text,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildReportInfo(Report report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(report.date),
          style: AppTheme.montserrat(
            color: AppTheme.text,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              "Report ID: ",
              style: AppTheme.montserrat(
                color: AppTheme.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              report.id,
              style: AppTheme.montserrat(
                color: AppTheme.text,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DNA Source: ",
              style: AppTheme.montserrat(
                color: AppTheme.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Text(
                report.filename,
                style: AppTheme.montserrat(
                  color: AppTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons(Report report) {
    return Row(
      spacing: 10,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.all(
                Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: () => _downloadPdf(report.id),
          child: Text(
            "Download",
            style: AppTheme.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBackground,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: AppTheme.border,
            disabledMouseCursor: SystemMouseCursors.forbidden,
            backgroundColor: AppTheme.primaryBlue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.all(
                Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: _isGlbButtonEnabled
              ? () => {
                    Navigator.pushNamed(
                      context,
                      "/reports-model-view",
                      arguments: {
                        'reportId': report.id,
                        'filename': report.filename,
                      },
                    )
                  }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isDownloading) ...[
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBackground),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _isDownloading ? "Preparing..." : "GLB View",
                style: AppTheme.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBackground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeading() {
    bool isSmallScreen = MediaQuery.of(context).size.width < 1500;
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            '/reports',
          ),
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.text,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        Text(
          "DNA-Based Phenotype & Ancestry Report",
          style: AppTheme.montserrat(
            fontSize: isSmallScreen ? 25 : 36,
            fontWeight: FontWeight.w800,
            color: AppTheme.text,
          ),
        ),
      ],
    );
  }

  Widget _buildRowHeader(Report report) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeading(),
        _buildButtons(report),
      ],
    );
  }

  Widget _buildColHeader(Report report) {
    return Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeading(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildButtons(report),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.border,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Error loading report',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () {
              setState(() {
                _reportFuture = _reportService.getReport(widget.reportId);
              });
            },
            child: Text(
              'Retry',
              style: AppTheme.montserrat(
                color: AppTheme.primaryBackground,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Text(
        'Report not found',
        style: AppTheme.montserrat(
          color: AppTheme.secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReportContent(Report report) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 64),
            Text(
              'Home / Reports / ${report.filename}',
              style: AppTheme.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 42),
            MediaQuery.of(context).size.width < 1500
                ? _buildColHeader(report)
                : _buildRowHeader(report),
            const SizedBox(height: 32),
            _buildReportInfo(report),
            const SizedBox(height: 32),
            _buildPredictionsTable(_predictions(report.predictions)),
            const SizedBox(height: 20),
            _buildReportImages(report),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildReportImages(Report report) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 900,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Face Prediction:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 7),
                _buildRuntimeImage(report.id, imageWidth),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ancestral Map:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 7),
                _buildRuntimeMap(
                  _getAncestryPrediction(report.predictions),
                  imageWidth,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.secondaryBackground,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 1500
                  ? 1500
                  : double.infinity,
              child: FutureBuilder<Report?>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState();
                  }

                  final report = snapshot.data;
                  if (report == null) {
                    return _buildNotFoundState();
                  }

                  return _buildReportContent(report);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
