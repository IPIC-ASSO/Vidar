import 'dart:async';
import 'package:flutter/material.dart';



class Usine {
  static Timer TempsgrillePain = Timer(const Duration(seconds: 2), () { });


  static void montreBiscotte(BuildContext context, String message, TickerProvider ticket, [bool positif = false]) {
    print("appel");
    OverlayEntry _overlayEntry;
    _overlayEntry = createOverlayEntry(context, message, ticket, positif);
    Overlay.of(context).insert(_overlayEntry);
    TempsgrillePain = Timer(const Duration(seconds: 4), () {
      _overlayEntry.remove();
    });
  }

  static OverlayEntry createOverlayEntry(BuildContext context,
      String message, TickerProvider ticket,bool positif) {
    AnimationController _controller = AnimationController(
      vsync: ticket,
      duration: const Duration(milliseconds: 500),
    ); // <-- Se
    _controller.forward()..whenComplete(() async {
      await Future.delayed(const Duration(seconds: 3));
      _controller.reverse();
    } );
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        width: MediaQuery.of(context).size.width/MediaQuery.of(context).size.height>1?MediaQuery.of(context).size.width/2:MediaQuery.of(context).size.width*0.7,
        left: MediaQuery.of(context).size.width/MediaQuery.of(context).size.height>1?MediaQuery.of(context).size.width*0.25:MediaQuery.of(context).size.width*0.15,
        child:AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
          return Transform.translate(
          offset: Offset(0, -100 * _controller.value+100),
          child:  Material(
            elevation: 10.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
              const EdgeInsets.only(left: 10, right: 10,
                  top: 13, bottom: 10),
              decoration: BoxDecoration(
                  color: positif?Colors.green:const Color(0xffe53e3f),
                  borderRadius: BorderRadius.circular(10)),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ));}),
      ));
  }
  
}

/*class ToastMessageAnimation extends StatelessWidget {
  final Widget child;

  ToastMessageAnimation(this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("translateY")
          .add(
        Duration(milliseconds: 250),
        Tween(begin: -100.0, end: 0.0),
        curve: Curves.easeOut,
      )
          .add(Duration(seconds: 1, milliseconds: 250),
          Tween(begin: 0.0, end: 0.0))
          .add(Duration(milliseconds: 250),
          Tween(begin: 0.0, end: -100.0),
          curve: Curves.easeIn),
      Track("opacity")
          .add(Duration(milliseconds: 500),
          Tween(begin: 0.0, end: 1.0))
          .add(Duration(seconds: 1),
          Tween(begin: 1.0, end: 1.0))
          .add(Duration(milliseconds: 500),
          Tween(begin: 1.0, end: 0.0)),
    ]);

    return ControlledAnimation(
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) =>
          Opacity(
            opacity: animation["opacity"],
            child: Transform.translate(
                offset: Offset(0, animation["translateY"]),
                child: child),
          ),
    );
  }
}*/