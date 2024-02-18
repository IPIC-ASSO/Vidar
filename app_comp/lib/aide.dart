import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import 'AppCouleur.dart';

class Aide extends StatefulWidget {

  const Aide({super.key});

  @override
  State<Aide> createState() => _AideState();
}

class _AideState extends State<Aide> with TickerProviderStateMixin {

  final controlleManege = CarouselController();
  int _indiceImage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(padding: const EdgeInsets.all(5),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction),
            const Text("Cette section n'est pas encore finalisée, nous attendons vos retours pour l'adapter au mieux.", textAlign: TextAlign.center,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton.icon(
                onPressed: ()=>{
                  showGeneralDialog(
                    context: context,
                    barrierColor: Colors.white,
                    barrierDismissible: false,
                    barrierLabel: 'Vidar-communication',
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, __, ___) {
                      final height = MediaQuery.of(context).size.height;
                      _indiceImage =0;
                      return StatefulBuilder(
                builder: (context, setState) {
                        return Stack(children: [
                          FlutterCarousel(
                            options: CarouselOptions(
                                controller: controlleManege,
                                height: height,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                autoPlay: true,
                                enableInfiniteScroll: false,
                                pauseAutoPlayInFiniteScroll: true,
                                autoPlayInterval: const Duration(seconds: 5),
                                slideIndicator: CircularSlideIndicator(
                                  indicatorBackgroundColor: Colors.black,
                                  currentIndicatorColor: AppCouleur.droitier
                                ),
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _indiceImage = index;
                                  });
                                }
                            ),
                            items: liste_transparents,),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () =>
                                  {
                                    Navigator.of(context).pop()
                                  },
                                  tooltip: "Fermer",
                                  icon: const Icon(Icons.close, size: 40),
                                ),
                              )
                          ),
                          Visibility(
                            visible:_indiceImage!=0,
                            child:Padding(
                              padding: const EdgeInsets.all(10),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FloatingActionButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0)),
                                  backgroundColor: AppCouleur().secondaire,
                                  onPressed: () =>
                                  {
                                    controlleManege.previousPage()
                                  },
                                  tooltip: "Image précédente",
                                  child: const Icon(Icons.arrow_back),
                                ),
                              )
                          ),),
                          Visibility(
                              visible: _indiceImage <
                                  liste_transparents.length - 1,
                              child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              50.0)),
                                      backgroundColor: AppCouleur().secondaire,
                                      onPressed: () =>
                                      {
                                        controlleManege.nextPage()
                                      },
                                      tooltip: "Image suivante",
                                      child: const Icon(Icons.arrow_forward),
                                    ),
                                  )
                              ))

                        ]
                        );
                      });
                    },
                  )
                },
                icon: const Icon(Icons.sticky_note_2_sharp),
                label: const Text("Tutoriel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppCouleur.tertiaire,
                  foregroundColor : AppCouleur.white,
                  minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                ),
              ),
            ),
          ],
        ))
    );
  }
}

List<String> textes = [
  "Communiquez n'importe où avec n'importe qui",
  "Pas besoin de parler, tout se passe par messages",
  "Un QR-code à flasher et vous pourrez chatter",
  "Pas d'information personnelle à fournir, l'échange reste confidentiel",
  "Il est également possible de pré-enregistrer et lire des messages"
];

final List<Widget> liste_transparents = List.generate(5, (index) =>
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Expanded(flex:1,child:Image.asset("assets/tutoriel/tuto_${index+1}.png", fit: BoxFit.fitWidth,)),
    Expanded(flex:0,child:Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10,0,10,70),

        child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
                children: <TextSpan>[
                TextSpan(
                text: textes[index]),
          ]
        ),
      ),
    ),
    )),

  ],
)

);


class SlidePercentageIndicator implements SlideIndicator {
  SlidePercentageIndicator({
    this.decimalPlaces = 0,
    this.style,
  });

  /// The number of decimal places to show in the output
  final int decimalPlaces;

  /// The text style to be used by the percentage text
  final TextStyle? style;

  @override
  Widget build(int currentPage, double pageDelta, int itemCount) {
    if (itemCount < 2) return const SizedBox.shrink();
    final step = 100 / (itemCount - 1);
    final percentage = step * (pageDelta + currentPage);
    return Center(
      child: Text(
        '${percentage.toStringAsFixed(decimalPlaces)}%',
        style: style ??
            const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}