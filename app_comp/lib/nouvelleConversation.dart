import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class NouvConv extends StatefulWidget {

  const NouvConv({super.key});

  @override
  State<NouvConv> createState() => _NouvConvState();
}

class _NouvConvState extends State<NouvConv> with TickerProviderStateMixin {

  late TabController controleTable;
  MobileScannerController controleCam = MobileScannerController();

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
              Container(child:MobileScanner(
                fit: BoxFit.contain,
                controller: controleCam,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  final Uint8List? image = capture.image;
                  for (final barcode in barcodes) {
                    debugPrint('Barcode found! ${barcode.rawValue}');
                    print("OOOOOOUUI");
                    controleTable.animateTo(0);
                  }
                },
              )),
          ]),
      floatingActionButton: controleTable.index == 1 ? FloatingActionButton(
        onPressed: () => {controleCam.switchCamera()},
        child: Icon(Icons.cameraswitch),
      ) : null,
    );
  }
}
