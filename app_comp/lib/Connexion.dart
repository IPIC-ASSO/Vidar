import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AppCouleur.dart';
import 'usineDeBiscottesGrillees.dart';

class Connexion extends StatefulWidget {

  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> with TickerProviderStateMixin{

  late TabController controleTable ;
  TextEditingController mail_co = TextEditingController();
  TextEditingController mdp_co = TextEditingController();
  TextEditingController mail_ins = TextEditingController();
  TextEditingController pseudo = TextEditingController();
  TextEditingController mdp_ins = TextEditingController();
  static final auth = FirebaseAuth.instance;
  bool mdpVisible = true;

  @override
  void initState() {
    super.initState();
    controleTable = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Authentification",),
        bottom: TabBar(
          controller: controleTable,
          tabs: [
            const Tab(icon: Icon(Icons.login), child:Text("Connexion",textAlign: TextAlign.center,)),
            const Tab(icon: Icon(Icons.nature_people_outlined), child:Text("Inscription",textAlign: TextAlign.center,)),
          ]
        )
      ),
      body: Column(children:[
          Container(
            width: 500,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Vidar - plateforme de communication',
                style: TextStyle(
                    color: AppCouleur.eco,
                    fontWeight: FontWeight.w500,
                    fontSize: 30),
                textAlign: TextAlign.center,
              )),
        Expanded(child: TabBarView(
          controller: controleTable,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: mail_co,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'email',
                        hintText: "adresse email",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      obscureText: mdpVisible,
                      controller: mdp_co,
                      onSubmitted: (value) => connecte(),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Mot de passe',
                        hintText: "Mot de passe",
                        suffixIcon: IconButton(onPressed: (){setState(() {
                          mdpVisible = !mdpVisible;
                        });}, icon: Icon(mdpVisible? Icons.visibility: Icons.visibility_off)),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showMyDialog();
                    },
                    child: const Text('Mot de passe oublié'),
                  ),
                  Container(
                      height: 70,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: ElevatedButton(
                        child: const Text('Se connecter',style: TextStyle(fontSize: 18),),
                        onPressed: () {
                          connecte();
                        },
                      )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Pas encore inscrit?'),
                      TextButton(
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(fontSize: 14),
                        ),
                        onPressed: () {
                          controleTable.animateTo(1);
                        },
                      )
                    ],
                  ),
                ],
              )),
          Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: mail_ins,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: "Adresse Email",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: pseudo,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nom d\'utilisateur',
                        hintText: "Nom d'utilisateur",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      controller: mdp_ins,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mot de passe',
                        hintText: "Mot de passe",
                      ),
                    ),
                  ),

                  Container(
                      height: 70,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: ElevatedButton(
                        child: const Text(
                          "S'inscrire", style: TextStyle(fontSize: 18),),
                        onPressed: () {
                          nouvUti();
                        },
                      )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Déjà inscrit?'),
                      TextButton(
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 14),
                        ),
                        onPressed: () {
                          controleTable.animateTo(0);
                        },
                      )
                    ],
                  ),
                ],
              )
            )
        ],
      ),),
    ]));
  }

  Future<void> resetPassword({required String email}) async {
    try{
      await auth
          .sendPasswordResetEmail(email: email)
          .then((value) => Usine.montreBiscotte(context, 'Envoyé!', this, true));
    }on FirebaseAuthException catch (e) {
      print(e.code);
      Usine.montreBiscotte(context, 'Une erreur est survenue. \nL\'accès à la Base données a échoué ', this);
    }catch(e){
      Usine.montreBiscotte(context, 'Une erreur est survenue', this);
    }
    return;
  }

  Future<void> _showMyDialog() async {
    final TextEditingController mailControl = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réinitialiser le mot de passe'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(10),
                    child:Text('Veuillez rentrer votre adresse e-mail\nUn lien de récupération va vous être envoyé (pensez à vérifier les spams)')),
                TextField(
                  controller: mailControl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'email',
                    hintText: "adresse email",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Envoyer'),
              onPressed: () async{
                if(mailControl.text.isNotEmpty) {
                  await resetPassword(email: mailControl.text);
                  Navigator.of(context).pop();
                }else {
                  Usine.montreBiscotte(context, "Oups, il nous faut une adresse e-mail", this);
                }
              },
            ),
            MaterialButton(onPressed: (){Navigator.of(context).pop();}, child: const Text('Annuler'),),
          ],
        );
      },
    );
  }

  void connecte() {
    if (auth.currentUser!=null){
      //Pouf il est connecté ! :=)
    }else if(mail_co.text.isNotEmpty && mdp_co.text.isNotEmpty) {
      try {
        auth.signInWithEmailAndPassword(email: mail_co.text, password: mdp_co.text);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Connexion...'),
        ));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Usine.montreBiscotte(context, "Utilisateur introuvable", this);
        } else if (e.code == 'wrong-password') {
          Usine.montreBiscotte(context, "Mot de passe incorrect", this);
        }
      } catch (e) {
        Usine.montreBiscotte(context, "Une erreur est survenue", this);
      }
    }else{
      Usine.montreBiscotte(context, "Oups, vous n'avez pas rempli tous les champs !", this);
    }
  }

  nouvUti() async{
    if(mail_ins.text.isNotEmpty && pseudo.text.isNotEmpty && mdp_ins.text.isNotEmpty){
      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Connexion...'),
        ));
        FirebaseFirestore db = FirebaseFirestore.instance;

        final credit = await auth.createUserWithEmailAndPassword(
          email: mail_ins.text.replaceAll(' ', ''),
          password: mdp_ins.text,
        );
        if (credit.user != null) {
          final user = <String, dynamic>{
            "pseudo": pseudo.text
            //TODO:messages ?
          };
          db
              .collection("Utilisateurs")
              .doc(credit.user?.uid ??
                  DateTime.now().millisecondsSinceEpoch.toString())
              .set(user)
              .then((value) => print('Utilisateur enregistré'))
              .onError((error, stackTrace) => print(error));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Usine.montreBiscotte(context, "Mot de passe trop faible", this);
        } else if (e.code == 'email-already-in-use') {
          Usine.montreBiscotte(
              context, "Adresse mail déjà utilisée par un utilisateur", this);
        } else {
          Usine.montreBiscotte(context, "Inscription impossible", this);
          print(e);
        }
      } catch (e) {
        print(e);
      }
    }else{
      Usine.montreBiscotte(context, "Oups! Vous n'avez pas rempli tous les champs", this);
    }
  }
}