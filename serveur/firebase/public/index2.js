var firebaseConfig = {
    apiKey: "AIzaSyBUb9qCgE0vdY7rqykD0T1O-I9x817TAhk",
    authDomain: "vidar-9e8ac.firebaseapp.com",
    databaseURL: "https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "vidar-9e8ac",
    storageBucket: "vidar-9e8ac.appspot.com",
    messagingSenderId: "276571176774",
    appId: "1:276571176774:web:725f1bbe89a6eb7097af47",

  };
firebase.initializeApp(firebaseConfig); //initialise le projet

const db = firebase.database();
var chemin = "";  //chemin vers la discussion
var utilisateur;
var pseudo;
var contact;

function inscrit(e){  //pour inscrire les nouveaux utilisateurs
  e.preventDefault();
  const email = document.getElementById("e-mail-inscr");
  const mdp = document.getElementById("mot-de-passe-inscr");
  const credential = firebase.auth.EmailAuthProvider.credential(email.value, mdp.value); 
  utilisateur.linkWithCredential(credential)
    .then((usercred) => {
      const ancUti = utilisateur;
      utilisateur = usercred.user;
      console.log("On vous a reconnu", utilisateur);
      db.ref("Users/" + utilisateur.uid).set({  //création de l'utilisateur dans la base de données
        id:utilisateur.uid,
        imageURL:defaut,
        username:document.getElementById("pseudo")
    });
      fermeFormulaire();  //ferme la fenêtre
    }).catch((error) => {
      console.log("Impossible de lier les comptes", error);
    });
}


function renomme(ancUti, nouvUti){ //changement valeurs anonyme a identifié
  db.ref("Users/"+ancUti.uid).remove(); //supr ancien utilisateur
  db.ref(chemin).get().then((snapshot)=>{
    const ancChats = snapshot;    //récupère l'ancienne conversation
  
    db.ref(chemin).remove();  //supprime l'ancienne conversation de la DB
    chemin  = "Chats/"+nouvUti.uid + destinataire+"/" //nouveau chemin pour les messages
    db.ref(chemin).set(ancChats)
    db.ref("ListeChats/"+ nouv.uid + destinataire).get().then((snapshot) =>{
      if (!snapshot.hasChildren()){ //initialise destinataire et envoyeur
        db.ref(cheminBase).set({
          utilisateur1:destinataire,
          utilisateur2:nouvUti.uid,
        });
      }
    });
    db.ref("ListeChats/"+ ancUti.uid + destinataire).remove();
  });
}

function deconnecte(){  //déconnexion
  firebase.auth().signOut(auth).then(() => {
      // Sign-out successful.
  }).catch((error) => {
      // An error happened :/
  });
}


function connecteAnonyme(){   //session temporaire
  firebase.auth().signInAnonymously()
  .then(() => {
    // Signed in..
    const uti = firebase.auth().currentUser
    const timestamp = Date.now();
    db.ref("Users/" + uti.uid).get().then((snapshot) =>{
      if (!snapshot.hasChildren()){
        db.ref("Users/" + uti.uid).set({  //créer l'utilisateur dans la base de données
          id:uti.uid,
          imageURL:"defaut",
          username: "utilisateur "+timestamp
        });
      }
    });
    $("#maison").removeClass("invisible");
  })
  .catch((error) => {
    var errorCode = error.code;
    var errorMessage = error.message;
    alert("Erreur, service indisponible "+errorCode+errorMessage)
  });
}

firebase.auth().onAuthStateChanged((user) => {  //écoute le changement de statut de l'utilisateur
  if (user) {//co
    utilisateur = user;
    initConv(destinataire);
  } else {//deco
  }
});

function charge_msg(){
  chemin2 = "/Users/"+utilisateur.uid+"/messages"
  const fetchChat = db.ref(chemin2); 
  //écoute l'arrivée de nouveaux messages
  fetchChat.on("child_added", function (snapshot) {
      listemsg = snapshot;
      const message = `<li class=msg_boite_leger id="${listemsg.key}">${listemsg.key}</li>`;
      // ajout de la balise dans la page
      document.getElementById("liste_des_messages").innerHTML += message;
  });
  fetchChat.on("child_removed",function(childSnapshot){
    document.getElementById("liste_des_messages").innerHTML=null;
    initmsg()
  });
}

function initConv(destinataire){  //créé une nouvelle conversation
  const cheminBase = "ListeChats/" + utilisateur.uid + destinataire;
  db.ref(cheminBase).get().then((snapshot) =>{
    if (!snapshot.hasChildren()){ //initialise destinataire et envoyeur
      db.ref(cheminBase).set({
        utilisateur1:destinataire,
        utilisateur2:utilisateur.uid,
      });
    }
    db.ref("Users/"+destinataire+"/contact").set(utilisateur.uid);  //met à jour le dernier contact
    chemin= "Chats/"+utilisateur.uid + destinataire+"/";  
    initFinale();
  });
}

function initFinale(){  //met en place les écouteurs et affiche les messages
  charge_msg();
  const chemin2 = "/Users/"+destinataire+"/username"
  db.ref(chemin2).get().then((snapshot) => {
    contact = "Inconnu au bataillon";
    if (snapshot.exists()) {
      contact = snapshot.val()
    }
    $("#destinataire").text(contact);
  })
  
  const fetchChat = db.ref(chemin); 

  //récupère le pseudo de l'utilisateur
  db.ref("Users/"+utilisateur.uid+"/username").once("value").then((snapshot) => {
    if (snapshot.exists()) {
      pseudo = snapshot.val();  //récupère le pseudo de l'utilisateur
    } else {
      console.log("No data available");
      alert("Impossible de récupérer votre profil :(")
    }
  }).catch((error) => {
    console.error(error);
  });

  //écoute l'arrivée de nouveaux messages
  document.getElementById("messages").innerHTML = null;
  fetchChat.on("child_added", function (snapshot) {
    const messages = snapshot.val();  //messages contient: l'envoyeur et le message
    const message = `<li class=${   //créer un nouvel élément <li> pour chaque message
      utilisateur.uid === messages.envoyeur ? "sent" : "receive"
    }>${messages.message}</li>`;
    /* <span>${messages.envoyeur}: </span> --> à ajouter pour avoir l'envoyeur*/ 
    // ajout de la balise dans la page
    document.getElementById("messages").innerHTML += message;
  }); 
}

function sendMessage(e) {
  e.preventDefault();
  // récupère les données
  const timestamp = Date.now();
  const messageInput = document.getElementById("message-input");
  const message = messageInput.value +"";

  // vide le champs de rédaction
  messageInput.value = "";

  //auto scroll
  document
    .getElementById("messages")
    .scrollIntoView({ behavior: "smooth", block: "end", inline: "nearest" });

  // envoit vers la base de données
  if (message.length>0){ 
    db.ref(chemin+timestamp).set({
      envoyeur:utilisateur.uid,
      message:message,
    });
  }
}


//--------DEBUT----------\\

const SessionCo = sessionStorage.getItem("co")
var destinataire = sessionStorage.getItem("destinataire");
if(destinataire==null){
  destinataire = prompt("Destinataire?"); //identifiant du destinataire (valeur que donne le QR-code). Le système avec un code n'est pas encore mis en place. Peut être sauté.
}

if (firebase.auth.currentUser==null && SessionCo == null){  //créé une session temporaire
  connecteAnonyme();  //session temporaire
}else{
  $(".open-button").addClass(".invisible")
}

document.getElementById("message-form").addEventListener("submit", sendMessage);

function afficheConnexion() {
  fermeFormulaire();
  document.getElementById("formulaireConnexion").style.display = "block";
}

function afficheInscription() {
  document.getElementById("formulaireInscription").style.display = "block";
}

function fermeFormulaire() {
  document.getElementById("formulaireConnexion").style.display = "none";
  document.getElementById("formulaireInscription").style.display = "none";
}

$("#mes_msg").click(function(event){
  $("#liste_des_messages").toggleClass("invisible");
})

$("#maison").on('click',function(event){
  window.location = "authentification.html";
})

$("#liste_des_messages").on("click", ".msg_boite_leger", function(event){
  const tete = this.textContent
  db.ref("/Users/"+utilisateur.uid+"/messages/"+tete).get().then((snapshot) => {
    if (snapshot.exists()) {
      $("#message-input").val($("#message-input").val()+snapshot.val());
    }
    $("#liste_des_messages").addClass("invisible");

  });
});