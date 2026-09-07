import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gemorph_flutter/theme/app_theme.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _hoveredButton = '';

  @override
  void dispose() {
    // Reset hover state to ensure clean disposal
    _hoveredButton = '';
    super.dispose();
  }

  /// Safely update hover state to prevent setState calls after disposal
  void _updateHoverState(String buttonId, bool isHovered) {
    if (mounted) {
      setState(() {
        _hoveredButton = isHovered ? buttonId : '';
      });
    }
  }

  Widget _buildWelcomeText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Welcome to",
            style: AppTheme.montserrat(
              fontSize: 52,
              fontWeight: FontWeight.w900,
            )),
        GradientText(
          " GeMorph",
          colors: const [
            Color(0xFFCC6E2B),
            Color(0xFFB94C48),
            Color(0xFF7328B5),
            Color(0xFF278EB5),
          ],
          style: AppTheme.montserrat(
            fontSize: 52,
            fontWeight: FontWeight.w900,
          ),
        )
      ],
    );
  }

  Widget _buildHeaderSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height < 620
          ? 300
          : 0.6 * MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image(
                image: AssetImage('assets/images/logo.png'),
                width: 221,
              ),
            ],
          ),
          Container(
            child: _buildWelcomeText(),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "What would you like to do?",
              style: AppTheme.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String buttonId,
    required String label,
    required Color backgroundColor,
    required String iconPath,
    required String route,
    required double defaultWidth,
    required double hoverWidth,
    required double defaultHeight,
    required double hoverHeight,
    required double iconSize,
    required double hoverIconSize,
  }) {
    final isHovered = _hoveredButton == buttonId;

    return ElevatedButton(
      onHover: (isHovered) {
        _updateHoverState(buttonId, isHovered);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(0),
      ),
      onPressed: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isHovered ? hoverWidth : defaultWidth,
        height: isHovered ? hoverHeight : defaultHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isHovered ? hoverIconSize : iconSize,
              width: isHovered ? hoverIconSize : iconSize,
              child: SvgPicture.asset(iconPath),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTheme.montserrat(
                fontSize: isHovered ? 14.4 : 12,
                fontWeight: FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 20,
        spacing: 40,
        children: [
          _buildAnimatedButton(
            buttonId: 'upload',
            label: 'Upload DNA',
            backgroundColor: const Color(0x80A1406C),
            iconPath: 'assets/icons/upload.svg',
            route: '/upload',
            defaultWidth: 140,
            hoverWidth: 167,
            defaultHeight: 45,
            hoverHeight: 55,
            iconSize: 22,
            hoverIconSize: 26,
          ),
          _buildAnimatedButton(
            buttonId: 'reports',
            label: 'Reports',
            backgroundColor: const Color(0x80CC6E2B),
            iconPath: 'assets/icons/document.svg',
            route: '/reports',
            defaultWidth: 114,
            hoverWidth: 138,
            defaultHeight: 45,
            hoverHeight: 54,
            iconSize: 19,
            hoverIconSize: 23,
          ),
          _buildAnimatedButton(
            buttonId: 'downloads',
            label: 'Downloads',
            backgroundColor: const Color(0x80B94C48),
            iconPath: 'assets/icons/download.svg',
            route: '/downloads',
            defaultWidth: 135,
            hoverWidth: 162,
            defaultHeight: 45,
            hoverHeight: 54,
            iconSize: 22,
            hoverIconSize: 26,
          ),
          _buildAnimatedButton(
            buttonId: 'about',
            label: 'About Us',
            backgroundColor: const Color(0x807328B5),
            iconPath: 'assets/icons/info.svg',
            route: '/about',
            defaultWidth: 122,
            hoverWidth: 147,
            defaultHeight: 45,
            hoverHeight: 54,
            iconSize: 24,
            hoverIconSize: 28.7,
          ),
          _buildAnimatedButton(
            buttonId: 'contact',
            label: 'Contact Us',
            backgroundColor: const Color(0x80278EB5),
            iconPath: 'assets/icons/mail.svg',
            route: '/contacts',
            defaultWidth: 135,
            hoverWidth: 162,
            defaultHeight: 45,
            hoverHeight: 54,
            iconSize: 19,
            hoverIconSize: 22,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(43),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/dna.png"),
              opacity: 0.2,
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 40),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
