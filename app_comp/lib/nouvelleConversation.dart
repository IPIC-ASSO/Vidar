import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';


class NouvConv extends StatefulWidget {

  const NouvConv({super.key});

  @override
  State<NouvConv> createState() => _NouvConvState();
}

class _NouvConvState extends State<NouvConv> with TickerProviderStateMixin {

  late TabController controleTable;

  @override
  void initState() {
    super.initState();
    print("a");
    controleTable = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Démarrer une conversation",),
          bottom: TabBar(
              isScrollable: true,
              controller: controleTable,
              tabs: [
                const Tab(icon: Icon(Icons.app_registration),
                    child: Text("Créer un QR-code", textAlign: TextAlign.center,)),
                const Tab(icon: Icon(Icons.qr_code_scanner),
                    child: Text("Scanner un QR-code", textAlign: TextAlign.center,)),
              ]
          )
      ),
        body:
          TabBarView(
            controller: controleTable,
            children: [
              Padding(padding: EdgeInsets.all(5),),
              Container(child:ElevatedButton(
              onPressed: () => scanQR(),
                child: Text('Start QR scan'))),
              ]),
    );
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      //_scanBarcode = barcodeScanRes;
    });
  }
}
