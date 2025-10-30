import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class UserQrScannerPage extends StatefulWidget {
  const UserQrScannerPage({super.key});

  @override
  State<UserQrScannerPage> createState() => _UserQrScannerPageState();
}

class _UserQrScannerPageState extends State<UserQrScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        // The admin panel now generates a UUID, not a URL.
        // The pharmacist scanner validates this UUID against a protected endpoint.
        // For a public scanner, we have a problem: the QR code contains a UUID, but there is no public endpoint to resolve it.

        // For now, let's assume the QR code contains the product ID and we can navigate to the public product detail page.
        // This means the admin QR code generation logic needs to be changed back to generating a URL.
        // Or, we need a new public endpoint like GET /api/products/by-qr/{qrCode}

        // Let's proceed with the assumption that we need a new public endpoint.
        // I will add a TODO here and discuss with the user.

        // For now, I will just display the scanned code.
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('QR Code Scanned'),
            content: Text('Scanned data: $code'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

      } else {
        _showError('QR Code is empty');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: _handleBarcode,
      ),
    );
  }
}
