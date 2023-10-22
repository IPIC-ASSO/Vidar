import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/Connexion.dart';
import 'package:vidar/Conversations.dart';
import 'package:vidar/Postier.dart';
import 'package:vidar/accueil.dart';
import 'package:vidar/listeMessages.dart';
import 'package:vidar/nouvelleConversation.dart';
import 'package:vidar/parametres.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vidar/patrons/MesConstantes.dart';
import 'package:vidar/qrcode.dart';

import 'firebase_options.dart';
import 'usineDeBiscottesGrillees.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  if(kIsWeb)await FirebaseFirestore.instance.enablePersistence(const PersistenceSettings(synchronizeTabs: true));
  else{
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(MonVidar());
}



class MonVidar extends StatefulWidget {
  const MonVidar({super.key});

  @override
  _MonVidarState createState() => _MonVidarState();

  static _MonVidarState of(BuildContext context) =>
      context.findAncestorStateOfType<_MonVidarState>()!;
}

/// Our State object
class _MonVidarState extends State<MonVidar> {
  /// 1) our themeMode "state" field
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vidar',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x84206EFF)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        toggleableActiveColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue, brightness: Brightness.dark)
            .copyWith( secondary: Colors.red),
        useMaterial3: true,
      ),
      themeMode: _themeMode, // 2) ← ← ← use "state" field here //////////////
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }

  /// 3) Call this to change theme from any context using "of" accessor
  /// e.g.:
  /// MonVidar.of(context).changeTheme(ThemeMode.dark);
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}



class MyHomePage extends StatefulWidget {

  final bool sessionConnecte;

  const MyHomePage({super.key, this.sessionConnecte = false});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>  with WidgetsBindingObserver, TickerProviderStateMixin{


  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth =  FirebaseAuth.instance;
  FirebaseMessaging messager = FirebaseMessaging.instance;
  late StreamSubscription<User?> ecouteur;
  bool connecte = false;

  @override
  initState() {
    super.initState();
    ecouteur = auth.authStateChanges().listen((User? user) async {
        if (user == null) {
         setState(() {
            connecte = false;
          });
        } else {
          if(user.isAnonymous){
            int nb = await laPoste(firebaseFirestore: db).prendPersoNb(user.uid);
            Future.delayed(Duration.zero).then((value) => Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => MontreQrCode(idUt:user.uid,messageAffiche:"",messageDebut:"",messageLu:"",tempo: true,nb:nb),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            )));
          }else{
            enregistreNotifieur();
            laPoste(firebaseFirestore: db).renotifie(auth.currentUser!.uid);
            setState(() {
              connecte = true;
            });
            Usine.montreBiscotte(context, "Bienvenue!", this, true);
          }
        }
    });
    if(kIsWeb){
      try {
        if(Uri.base.queryParameters["dest"]!=null && auth.currentUser!=null){
              traiteCode(Uri.base.queryParameters["dest"]!,auth.currentUser!.uid,db,context);
                html.window.history.pushState(null, 'iren', '#/iren');
              }else if(!connecte && !widget.sessionConnecte){
                Future.delayed(Duration.zero).then((value) =>
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder:(_, __, ___) => const Accueil(),
                      transitionDuration: const Duration(milliseconds: 500),
                      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                    )));
                  }
      } on FirebaseException catch(e){
          switch (e.code){
            case 'not-found':
              Usine.montreBiscotte(context, "Code invalide", this);
              break;
            default:
              Usine.montreBiscotte(context, "La base de donnée refuse la transaction", this);
          }
        }
        catch (e) {
          log(e.toString());
          Usine.montreBiscotte(context, "Une erreur est survenue", this);
        }
      }
    WidgetsBinding.instance.addObserver(this);
    /*SharedPreferences.getInstance().then((value) {
      value;
      setState(() {
        if(value.getBool("nuit")??false){
          MonVidar.of(context).changeTheme(ThemeMode.dark);
        }
      });
    });*/
    }

  List<Widget> pages = [
    const Center(
      child: Conversations(),
    ),
    Center(
      child: ListeMessages(idUti: (FirebaseAuth.instance.currentUser?.uid??"erreur"))
    ),
    const Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction),
          Text("Nous attendons les retours des testeurs (vos retours;) ) pour rédiger au mieux cette section essentielle.")
        ],
      ),
    ),
    const Center(
      child: Parametres(),
    ),
  ];
  int indiceChoisi = 0;

  @override
  Widget build(BuildContext context) {
    if(connecte){
      if (MediaQuery.of(context).size.height /
          MediaQuery.of(context).size.width > 1) {
        return
        WillPopScope( onWillPop: ()async{
            ecouteur.cancel();
            return true;
          },
          child:Scaffold(
            body: Center(
              child: pages.elementAt(indiceChoisi), //New
            ),
            bottomNavigationBar: BottomNavigationBar( //TODO: disparait lors du scroll
              selectedFontSize: 18,
              unselectedItemColor: Colors.black,
              selectedItemColor: AppCouleur().principal,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              mouseCursor: SystemMouseCursors.grab,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Conversations',
                    tooltip: 'Liste des conversations'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.text_snippet_outlined),
                    label: 'Messages',
                    tooltip: 'Messages enregistrés'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.live_help_outlined),
                    label: 'Aide',
                    tooltip: 'Aide'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Paramètres',
                    tooltip: 'Paramètres'
                ),
              ],
              currentIndex: indiceChoisi,
              //New
              onTap: (index) {
                setState(() {
                  indiceChoisi = index;
                });
              },
            ),
          )
    );
      } else {
        return Scaffold(
          body: Row(
            children: [
              /// Pretty similar to the BottomNavigationBar!
              SideNavigationBar(
                theme: SideNavigationBarTheme(
                  backgroundColor: AppCouleur.grisTre,
                  togglerTheme: SideNavigationBarTogglerTheme.standard(),
                  itemTheme: SideNavigationBarItemTheme.standard(),
                  dividerTheme: SideNavigationBarDividerTheme.standard(),
                ),
                selectedIndex: indiceChoisi,
                items: const [
                  SideNavigationBarItem(
                    icon: Icons.chat,
                    label: 'Conversations',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.text_snippet_outlined,
                    label: 'Messages',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.live_help_outlined,
                    label: 'Aide',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.settings,
                    label: 'Paramètres',
                  ),
                ],
                onTap: (index) {
                  setState(() {
                    indiceChoisi = index;
                  });
                },
              ),

              /// Make it take the rest of the available width
              Expanded(
                flex: 1,
                child: pages.elementAt(indiceChoisi),
              )
            ],
          ),
        );
      }
    }
    else{
      return const Connexion();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && auth.currentUser!=null) {
      laPoste(firebaseFirestore: db).renotifie(auth.currentUser!.uid);
    } else if (state == AppLifecycleState.resumed) {

    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> enregistreNotifieur() async {
    await messager.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //firebaseMessagingBackgroundHandler(message);
    });
    messager.getToken().then((token) {
      print('token: $token');
      db.collection(MesConstantes.cheminUtilisateur).doc(auth.currentUser!.uid).update({MesConstantes.jeton: token});
    }).catchError((err) {
      Usine.montreBiscotte(context, err.message.toString(), this);
    });
  }


}

/*Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('onMessage: $message');
  if (message.notification != null) {
    print(message.notification?.body);
    //showNotification(message.notification!);
  }
  return;
}*/


