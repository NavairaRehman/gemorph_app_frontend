import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar_scaffold.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  late Future<List<Report>> _reportsFuture;
  final ScrollController _scrollController = ScrollController();
  int hover = -1;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadReports() {
    setState(() {
      _reportsFuture = _reportService
          .listReports()
          .then((reports) => reports.reversed.toList());
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 64),
        Text(
          'Home / Reports',
          style: AppTheme.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 42),
        Padding(
          padding: EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Text(
                'Reports',
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
                onPressed: _loadReports,
              ),
            ],
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
                const SizedBox(height: 24),
                Expanded(
                  child: FutureBuilder<List<Report>>(
                    future: _reportsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.text,
                          ),
                        );
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
          ), // Placeholder for the actual content
        ),
      ),
    );
  }

  Widget _buildReportsList(List<Report> reports) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: reports.length,
        separatorBuilder: (context, index) => const SizedBox(height: 13),
        itemBuilder: (context, index) {
          final report = reports[index];
          return MouseRegion(
            cursor: hover == index
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: (event) {
              setState(() {
                hover = index;
              });
            },
            onExit: (event) {
              setState(() {
                hover = -1;
              });
            },
            child: ElevatedButton(
              onPressed: () => _navigateToDetail(report.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Container(
                width: double.infinity,
                height: 86,
                decoration: BoxDecoration(
                  color: hover == index
                      ? const Color(0xFF202020)
                      : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.border,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/document.svg",
                      width: 26,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        report.status == 'completed'
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
                            report.filename,
                            style: AppTheme.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.text,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Status: ${report.status}",
                            style: AppTheme.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                          Text(
                            "Date: ${_formatDate(report.date)}",
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
            ),
          );
        },
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
            'Failed to load reports',
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
            'No reports found',
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

  void _navigateToDetail(String reportId) {
    Navigator.pushReplacementNamed(
      context,
      "/reports-details",
      arguments: {
        'reportId': reportId,
      },
    );
  }
}
