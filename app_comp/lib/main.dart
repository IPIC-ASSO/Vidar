import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:vidar/Connexion.dart';
import 'package:vidar/Conversations.dart';


import 'firebase_options.dart';
import 'usineDeBiscottesGrillees.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      //TODO: crashlitics;
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vidar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x2B4689FF)),
        useMaterial3: true,
          canvasColor: Color(0xFF4BC08F),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});

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
          connecte= false;
        });
      } else {
        setState(() {
          connecte = true;
        });
        Usine.montreBiscotte(context, "Bienvenue!", this,true);
      }
    });

  }

  List<Widget> pages = const [
    Center(
      child: Conversations(),
    ),
    Center(
      child: Text('Messages'),
    ),
    Center(
      child: Text('Paramètres'),
    ),
    Center(
      child: Text('Aide'),
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
            selectedItemColor: Colors.blue[800],
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
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
                child: pages.elementAt(indiceChoisi),
              )
            ],
          ),
        );
      }
    }else{
      return Connexion();
    }

  }

}
