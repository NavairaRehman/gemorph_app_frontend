import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gemorph_flutter/theme/app_theme.dart';

class SidebarScaffold extends StatefulWidget {
  final Widget child;

  const SidebarScaffold({
    super.key,
    required this.child,
  });

  @override
  State<SidebarScaffold> createState() => _SideBarScaffoldState();
}

class _SideBarScaffoldState extends State<SidebarScaffold> {
  final List<Map<String, dynamic>> _drawerItems = [
    {
      'title': 'Home',
      'icon': 'assets/icons/home.svg',
      "route": '/home',
      "width": 24.0,
      "height": 24.0,
    },
    {
      'title': 'Upload DNA',
      'icon': 'assets/icons/upload.svg',
      "route": '/upload',
      "width": 18.0,
      "height": 18.0,
    },
    {
      'title': 'Reports',
      'icon': 'assets/icons/document.svg',
      "route": '/reports',
      "width": 16.0,
      "height": 20.0,
    },
    {
      'title': 'Downloads',
      'icon': 'assets/icons/download.svg',
      "route": '/downloads',
      "width": 18.0,
      "height": 18.0,
    },
    {
      'title': 'About Us',
      'icon': 'assets/icons/info.svg',
      "route": '/about',
      "width": 20.0,
      "height": 20.0,
    },
    {
      'title': 'Contacts',
      'icon': 'assets/icons/mail.svg',
      "route": '/contacts',
      "width": 20.0,
      "height": 16.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    bool isSmallScreen = MediaQuery.of(context).size.width < 1000;
    double sidebarWidth = isSmallScreen ? 100 : 320;

    bool isActiveRoute(String route) {
      return currentRoute?.contains(route) ?? false;
    }

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height < 750
              ? 750
              : MediaQuery.of(context).size.height,
          child: Row(
            children: [
              Container(
                width: sidebarWidth,
                color: AppTheme.primaryBackground,
                child: Padding(
                  padding: isSmallScreen
                      ? const EdgeInsets.symmetric(vertical: 20, horizontal: 12)
                      : EdgeInsets.all(sidebarWidth * 0.09),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                          image: isSmallScreen
                              ? const AssetImage('assets/images/logo_only.png')
                              : const AssetImage('assets/images/logo.png'),
                          width: isSmallScreen ? 50 : 180),
                      const SizedBox(height: 60),
                      ..._drawerItems.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isActiveRoute(item["route"])
                                ? AppTheme.primaryPurple.withValues(alpha: 0.1)
                                : Colors.transparent,
                          ),
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              item["route"],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: isSmallScreen
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    item["icon"]!,
                                    width: 20,
                                    height: 20,
                                    colorFilter: ColorFilter.mode(
                                      isActiveRoute(item["route"])
                                          ? AppTheme.primaryPurple
                                          : AppTheme.text,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  isSmallScreen
                                      ? const SizedBox()
                                      : const SizedBox(width: 20),
                                  isSmallScreen
                                      ? Container()
                                      : Text(
                                          item["title"]!,
                                          style: AppTheme.montserrat(
                                            fontSize:
                                                isActiveRoute(item["route"])
                                                    ? 12
                                                    : 11,
                                            color: isActiveRoute(item["route"])
                                                ? AppTheme.primaryPurple
                                                : AppTheme.text,
                                            fontWeight:
                                                isActiveRoute(item["route"])
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              // Main content area
              Expanded(
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
