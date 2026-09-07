import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:gemorph_flutter/config/app_config.dart';
import 'package:gemorph_flutter/theme/app_theme.dart';
import 'package:gemorph_flutter/widgets/glb_model_viewer.dart';
import 'package:gemorph_flutter/widgets/sidebar_scaffold.dart';
import 'package:path_provider/path_provider.dart';

class FaceModelScreen extends StatefulWidget {
  final String reportId;
  final String filename;
  const FaceModelScreen(
      {super.key, required this.reportId, required this.filename});

  @override
  State<FaceModelScreen> createState() => _FaceModelScreenState();
}

class _FaceModelScreenState extends State<FaceModelScreen> {
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 64),
        Text(
          "Home / Reports / ${widget.filename} / 3D Model",
          style: AppTheme.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 42),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
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
                  "3D Facial Model",
                  style: AppTheme.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 42),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.border.withValues(alpha: 0.3),
                      border: Border.all(color: AppTheme.border, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF1E1E1E),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    height: 700,
                    width: double.infinity,
                    child: ClipRRect(
                      child: kIsWeb
                          ? GlbModelViewer(
                              src:
                                  '${AppConfig.baseUrl}/glb/${widget.reportId}/download',
                            )
                          : Cube(
                              interactive: true,
                              onSceneCreated: (Scene scene) async {
                                final tempDir = await getTemporaryDirectory();
                                final modelDir =
                                    Directory('${tempDir.path}/3d_model/');
                                final object = Object(
                                  fileName:
                                      "${modelDir.path}/${widget.reportId}.obj",
                                  backfaceCulling: true,
                                  isAsset: false,
                                );
                                object.scale.setFrom(Vector3.all(5.0));
                                object.updateTransform();
                                scene.world.add(object);
                                scene.camera.position
                                    .setFrom(Vector3(0, 0, 10));
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
