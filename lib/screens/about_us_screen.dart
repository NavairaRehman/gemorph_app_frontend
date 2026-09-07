import 'package:flutter/material.dart';
import 'package:gemorph_flutter/theme/app_theme.dart';
import 'package:gemorph_flutter/widgets/sidebar_scaffold.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 64),
        Text(
          'Home / About Us',
          style: AppTheme.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.text,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Center(
                  child: Column(
                    children: [
                      const Image(
                        image: AssetImage("assets/images/logo_2.png"),
                        width: 177,
                        height: 203,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 740,
                        child: Text(
                          "GeMorph is an innovative platform that predicts 3D facial models, skin, hair, and eye colors from DNA data. Our mission is to empower researchers, forensic experts, and individuals with cutting-edge genomics technology. By combining AI and genomics, we transform genetic insights into realistic, visual representations.\nAt GeMorph, we believe in responsible innovation, data privacy and scientific advancement. Our team is passionate about bridging the gap between DNA science and real-world applications.",
                          style: AppTheme.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.text,
                            lineHeight: 1.71,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the upload-dna screen
                          Navigator.pushReplacementNamed(context, '/upload');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Get Started",
                          style: AppTheme.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryBackground),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "",
                      style: AppTheme.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                )
              ],
            ),
          ), // Placeholder for the actual content
        ),
      ),
    );
  }
}
