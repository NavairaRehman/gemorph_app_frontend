import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class GlbModelViewer extends StatefulWidget {
  final String src;

  const GlbModelViewer({super.key, required this.src});

  @override
  State<GlbModelViewer> createState() => _GlbModelViewerState();
}

class _GlbModelViewerState extends State<GlbModelViewer> {
  static final Set<String> _registeredViewTypes = {};
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'gemorph-glb-viewer-${widget.src.hashCode}';

    if (_registeredViewTypes.add(_viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final viewer = html.Element.tag('model-viewer')
          ..setAttribute('src', widget.src)
          ..setAttribute('alt', 'Generated 3D facial model')
          ..setAttribute('camera-controls', '')
          ..setAttribute('auto-rotate', '')
          ..setAttribute('shadow-intensity', '1')
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#242424';

        return html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..children.add(viewer);
      });
    }
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
