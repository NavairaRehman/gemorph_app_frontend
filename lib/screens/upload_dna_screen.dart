import 'package:flutter/material.dart';
import 'package:gemorph_flutter/theme/app_theme.dart';
import 'package:gemorph_flutter/widgets/file_upload_section.dart';
import 'package:gemorph_flutter/widgets/sidebar_scaffold.dart';

class UploadDNAScreen extends StatelessWidget {
  const UploadDNAScreen({super.key});

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Home / Upload DNA',
        style: AppTheme.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.text,
        ),
      ),
      const SizedBox(height: 42),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.secondaryBackground,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
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
                const FileUploadSection(),
              ],
            ),
          ), // Placeholder for the actual content
        ),
      ),
    );
  }
}
