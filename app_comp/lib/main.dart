import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/Connexion.dart';
import 'package:vidar/Conversations.dart';
import 'package:vidar/accueil.dart';
import 'package:vidar/listeMessages.dart';
import 'package:vidar/nouvelleConversation.dart';
import 'package:vidar/parametres.dart';
import 'package:universal_html/html.dart' as html;

import 'firebase_options.dart';
import 'usineDeBiscottesGrillees.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  if(kIsWeb)await FirebaseFirestore.instance.enablePersistence(const PersistenceSettings(synchronizeTabs: true));
      //TODO: crashlitics;
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MonIpic());
}

class MonIpic extends StatelessWidget {
  const MonIpic({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vidar',
      theme: ThemeData(
        scaffoldBackgroundColor: AppCouleur.blanc,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x2B4689FF)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  final bool sessionConnecte;

  const MyHomePage({super.key, this.sessionConnecte = false});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  bool connecte = false;

  @override
  void initState(){
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
         setState(() {
            connecte = false;
          });
        } else {
            setState(() {
              connecte = true;
            });
            Usine.montreBiscotte(context, "Bienvenue!", this, true);
          }
    });
    print(widget.sessionConnecte);
    print("conncte: $connecte");
    if(kIsWeb){
      if(Uri.base.queryParameters["dest"]!=null && FirebaseAuth.instance.currentUser!=null){
        traiteCode(Uri.base.queryParameters["dest"]!,FirebaseAuth.instance.currentUser!.uid,FirebaseFirestore.instance,context);
        html.window.history.pushState(null, 'iren', '#/iren');
      }else if(!connecte && !widget.sessionConnecte){
        Future.delayed(Duration.zero).then((value) =>
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => const Accueil(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            )));
        }
      }
    }

  List<Widget> pages = [
    const Center(
      child: Conversations(),
    ),
    Center(
      child: ListeMessages(idUti: (FirebaseAuth.instance.currentUser?.uid??"erreur"))
    ),
    const Center(
      child: Text('Aide (toi et puis voila)'),
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
        return Scaffold(
          body: Center(
            child: pages.elementAt(indiceChoisi), //New
          ),
          bottomNavigationBar: BottomNavigationBar( //TODO: disparait lors du scroll
            selectedFontSize: 18,
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.blue[800],
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
        );
      } else {
        return Scaffold(
          body: Row(
            children: [
              /// Pretty similar to the BottomNavigationBar!
              SideNavigationBar(
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

}
