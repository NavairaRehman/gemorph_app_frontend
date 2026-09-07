import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gemorph_flutter/config/app_config.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar_scaffold.dart';
import '../services/download_service.dart';

class AllResultsScreen extends StatefulWidget {
  const AllResultsScreen({super.key});

  @override
  State<AllResultsScreen> createState() => _AllResultsScreenState();
}

class _AllResultsScreenState extends State<AllResultsScreen> {
  late Future<List<Result>> _resultsFuture;
  final _downloadService = DownloadService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDownloads() {
    setState(() {
      _resultsFuture = _downloadService.listOutputFiles();
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 64),
        Text(
          'Home / Downloads',
          style: AppTheme.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 42),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Text(
              'Downloads',
              style: AppTheme.montserrat(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppTheme.text,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: AppTheme.secondaryText,
                size: 24,
              ),
              onPressed: _loadDownloads,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.text,
      ),
    );
  }

  ButtonStyle _getDownloadButtonStyle() {
    return ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppTheme.primaryBlue.withValues(alpha: 0.3);
          }
          return AppTheme.primaryBlue;
        },
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildResultItem(Result result) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 86,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.border,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.only(left: 32, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20,
            children: [
              SvgPicture.asset(
                "assets/icons/document.svg",
                width: 26,
                height: 32,
                colorFilter: ColorFilter.mode(
                  result.status == 'completed'
                      ? AppTheme.primaryBlue
                      : Colors.red,
                  BlendMode.srcIn,
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 3,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      result.filename,
                      style: AppTheme.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Status: ${result.status}",
                      style: AppTheme.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Text(
                      "Date: ${_formatDate(result.date)}",
                      style: AppTheme.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryText,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 167.6,
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () => _downloadPdf(result.id),
              style: _getDownloadButtonStyle(),
              child: Text(
                "Download PDF",
                style: AppTheme.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBackground,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 10,
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () => _downloadGlb(result.id),
              style: _getDownloadButtonStyle(),
              child: Text(
                "Download GLB",
                style: AppTheme.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBackground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      child: Container(
        color: AppTheme.secondaryBackground,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 1500
                ? 1500
                : double.infinity,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: FutureBuilder<List<Result>>(
                    future: _resultsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState();
                      }

                      final reports = snapshot.data;
                      if (reports == null || reports.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildReportsList(reports);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList(List<Result> results) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: results.length,
        separatorBuilder: (context, index) => const SizedBox(height: 13),
        itemBuilder: (context, index) => _buildResultItem(results[index]),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load results',
            style: AppTheme.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 170),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.find_in_page,
            color: AppTheme.border,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: AppTheme.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 170),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(String fileId) async {
    const baseUrl = AppConfig.baseUrl; // Change if running on a server
    final url = Uri.parse('$baseUrl/reports/$fileId/download');

    try {
      if (Platform.isWindows) {
        Process.run('start', [url.toString()], runInShell: true);
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

  Future<void> _downloadGlb(String fileId) async {
    const baseUrl = AppConfig.baseUrl; // Change if running on a server
    final url = Uri.parse('$baseUrl/glb/$fileId/download');

    try {
      if (Platform.isWindows) {
        Process.run('start', [url.toString()], runInShell: true);
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
}
