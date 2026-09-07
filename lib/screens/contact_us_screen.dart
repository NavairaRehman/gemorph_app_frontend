import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gemorph_flutter/theme/app_theme.dart';
import 'package:gemorph_flutter/widgets/sidebar_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 64),
        Text(
          'Home / Contact Us',
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
                      SvgPicture.asset(
                        "assets/icons/mail_2.svg",
                        width: 108,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Contact Us",
                        style: AppTheme.montserrat(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 42),
                      Text(
                        "Official Email:",
                        style: AppTheme.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.text,
                          lineHeight: 1.71,
                        ),
                      ),
                      Text(
                        "gemorph24@gmail.com",
                        style: AppTheme.montserrat(
                          fontSize: 14,
                          lineHeight: 1.71,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.text.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Follow Us",
                        style: AppTheme.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.text,
                          lineHeight: 1.71,
                        ),
                      ),
                      Row(
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Text("Whatsapp",
                                style: AppTheme.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.text.withValues(alpha: 0.5),
                                )),
                            onTap: () => launchUrl(
                                Uri.parse("https://wa.me/923393965633")),
                          ),
                          InkWell(
                            child: Text("LinkedIn",
                                style: AppTheme.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.text.withValues(alpha: 0.5),
                                )),
                            onTap: () => launchUrl(Uri.parse(
                                "https://www.linkedin.com/company/gemorph")),
                          ),
                          InkWell(
                            child: Text("Instagram",
                                style: AppTheme.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.text.withValues(alpha: 0.5),
                                )),
                            onTap: () => launchUrl(Uri.parse(
                                "https://www.instagram.com/ge_morph?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw==")),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Founders",
                        style: AppTheme.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.text,
                          lineHeight: 1.71,
                        ),
                      ),
                      Text(
                        "Syed Ahsan Ullah Tanweer\nNavaira Rehman\nSyeda Fatima Roshan Haneef",
                        style: AppTheme.montserrat(
                          fontSize: 14,
                          lineHeight: 1.71,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.text.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 64),
                    Text(
                      '',
                      style: AppTheme.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ), // Placeholder for the actual content
        ),
      ),
    );
  }
}
