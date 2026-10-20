import 'package:flutter/material.dart';


import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n.dart';
import '../layout.dart';

/// Fullscreen QR scanner; pops the first detected string.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: pageBar(context, title: Text(context.t.scanCode), help: PageHelp('scan')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_done) return;
          final value = capture.barcodes.firstOrNull?.rawValue;
          if (value != null && value.isNotEmpty) {
            _done = true;
            Navigator.of(context).pop(value);
          }
        },
      ),
    );
  }
}
