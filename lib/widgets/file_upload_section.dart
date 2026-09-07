import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../services/report_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final List<_ProgressStep> _progressSteps = [
  _ProgressStep(
      "start", 'Starting processing', const Duration(milliseconds: 2000), 0),
  _ProgressStep("file-saved", 'Saving uploaded file',
      const Duration(milliseconds: 2000), 10),
  _ProgressStep("dna-preprocessing", 'Preprocessing DNA file',
      const Duration(milliseconds: 5000), 20),
  _ProgressStep("classification-models", 'Running classification models',
      const Duration(milliseconds: 5000), 45),
  _ProgressStep("predict-eye-color", 'Predicting eye color',
      const Duration(milliseconds: 1200), 50),
  _ProgressStep("predict-hair-color", 'Predicting hair color',
      const Duration(milliseconds: 1200), 55),
  _ProgressStep("predict-skin-tone", 'Predicting skin tone',
      const Duration(milliseconds: 1200), 60),
  _ProgressStep("face-mesh", 'Generating 3D face mesh',
      const Duration(milliseconds: 5000), 65),
  _ProgressStep("face-textures", 'Creating face textures',
      const Duration(milliseconds: 5000), 80),
  _ProgressStep("pdf-report", 'Generating PDF report',
      const Duration(milliseconds: 2000), 90),
  _ProgressStep("completed", 'Processing completed successfully',
      const Duration(milliseconds: 1500), 100),
];

class _ProgressStep {
  final String id;
  final String label;
  final Duration delay;
  final int percentage;
  _ProgressStep(this.id, this.label, this.delay, this.percentage);
}

class FileUploadSection extends StatefulWidget {
  const FileUploadSection({Key? key}) : super(key: key);

  @override
  _FileUploadSectionState createState() => _FileUploadSectionState();
}

class _FileUploadSectionState extends State<FileUploadSection> {
  String? _fileName;
  String? _filePath;
  Uint8List? _fileBytes;
  bool _isUploading = false;
  bool _fileEntered = false;
  int _currentStep = 0;
  final ScrollController scrollController = ScrollController();

  Future<void> _pickFile() async {
    if (_isUploading) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'vcf', 'csv'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        if (kIsWeb) {
          _fileBytes = result.files.single.bytes;
        } else {
          _filePath = result.files.single.path;
        }
      });
    }
  }

  Future<void> updateProgressTo(int index) async {
    if (!mounted) return;

    while (_currentStep < index && _currentStep + 1 < _progressSteps.length) {
      final step = _progressSteps[_currentStep + 1];
      if (mounted) {
        setState(() {
          _currentStep = _currentStep + 1;
        });
        scrollController.animateTo(
          _currentStep * 20.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      await Future.delayed(step.delay);
    }
  }

  Future<void> _uploadFile() async {
    if ((kIsWeb && (_fileBytes == null || _fileName == null)) ||
        (!kIsWeb && (_filePath == null || _fileName == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _currentStep = 0;
    });

    try {
      final reportService = ReportService();

      // 0) Read the file bytes into a single variable
      final Uint8List fileBytes =
          kIsWeb ? _fileBytes! : await File(_filePath!).readAsBytes();

      // 1) Upload to backend, get fileId
      final String fileId = await reportService.uploadDNA(
        fileBytes,
        _fileName!,
      );

      // 2) Poll until processing is done
      await for (final progress in reportService.waitForCompletion(fileId)) {
        if (!mounted) return;

        final stepIndex = _progressSteps.indexWhere((step) {
          return step.id == progress.step;
        });

        if (stepIndex >= 0) {
          await updateProgressTo(stepIndex);
        }

        if (progress.step == "completed") {
          break;
        } else if (progress.step == "error") {
          print("Error during processing: ${progress.step}");
        }
      }

      // 3) Fetch the completed report JSON
      final report = await reportService.getReport(fileId);

      if (!mounted) return;

      // 4) Navigate to the new report
      Navigator.pushReplacementNamed(
        context,
        "/reports-details",
        arguments: {
          'reportId': report.id,
          'returnRoute': '/reports',
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  bool _isValidExtenstion(DropItem file) {
    final fileExt = file.name.split(".").last;

    if (fileExt != "txt" && fileExt != "vcf" && fileExt != "csv") {
      return false;
    }
    return true;
  }

  void _handleDragDrop(List<DropItem> files) {
    if (_isUploading) return;

    if (files.isNotEmpty) {
      final file = files.first;

      if (!_isValidExtenstion(file)) {
        setState(() {
          _fileName = null;
          _filePath = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid file type. Supported: .txt, .vcf, .csv'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _filePath = file.path;
        _fileName = file.name;
      });
    }
  }

  Widget _showProgressText(index) {
    int processingStepIndex = index;

    return SizedBox(
      height: 60, // <-- set your fixed height here
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(" "),
            ..._progressSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;

              return SizedBox(
                height: 20,
                child: index == processingStepIndex
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            step.label,
                            style: AppTheme.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.text,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SpinKitFadingCircle(
                            color: AppTheme.text,
                            size: 14,
                          )
                        ],
                      )
                    : Text(
                        step.label,
                        style: AppTheme.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.secondaryText,
                        ),
                      ),
              );
            }).toList(),
            const Text(" "),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dropTarget = DropTarget(
      onDragEntered: (details) => {
        setState(() {
          _fileEntered = true;
        })
      },
      onDragExited: (details) => {
        setState(() {
          _fileEntered = false;
        })
      },
      onDragDone: (details) => _handleDragDrop(details.files),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => {
          setState(() {
            _fileEntered = true;
          })
        },
        onExit: (event) => {
          setState(() {
            _fileEntered = false;
          })
        },
        child: DottedBorder(
          options: const RoundedRectDottedBorderOptions(
            radius: Radius.circular(10),
            color: AppTheme.border,
            dashPattern: [10, 5],
            strokeWidth: 1,
            padding: EdgeInsets.all(0.5),
          ),
          child: Container(
            height: 282,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _fileEntered
                  ? const Color(0xFF2F2F2F)
                  : const Color(0xFF262626),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                SvgPicture.asset(
                  'assets/icons/upload_2.svg',
                  width: 57,
                  height: 57,
                ),
                SizedBox(
                  width: 190,
                  child: Text(
                    "Drag & drop your DNA file or click to browse",
                    style: AppTheme.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_fileName != null)
                  Text(
                    _fileName!,
                    style: AppTheme.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Choose File",
                      style: AppTheme.montserrat(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.zero,
          child: Text(
            'Upload DNA data',
            style: AppTheme.montserrat(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppTheme.text,
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: Text(
            'Supported file types: .txt, .vcf, .csv',
            style: AppTheme.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryText,
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickFile,
          child: dropTarget,
        ),
        if (_isUploading)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _showProgressText(_currentStep),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: const Color(0xFF262626),
                value: _progressSteps[_currentStep].percentage / 100,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ],
          ),
        const SizedBox(height: 20),
        SizedBox(
          height: 35,
          width: 140,
          child: ElevatedButton(
            onPressed: _isUploading ? () {} : _uploadFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isUploading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: AppTheme.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Submit",
                    style: AppTheme.montserrat(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        )
      ],
    );
  }
}
