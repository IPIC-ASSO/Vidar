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
var utilisateur;
var drapeau =0;
const SessionCo = sessionStorage.getItem("co")


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
    $()
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
    generateBarCode(utilisateur.uid);
    drapeau=0;
    ecouteScan(utilisateur.uid);
  } else {//deco
  }
});

function onScanSuccess(decodedText, decodedResult) {
  envoieCode(decodedResult);
}

function envoieCode(code){
  code = code.toString.replace("https://","");
  code = code.replace("vidar-9e8ac.web.app/?dest=","");
  sessionStorage.setItem("destinataire",code);
  window.location = "index2.html";

}

function generateBarCode(code) 
{
    var nric = $('#text').val();
    var url = 'https://api.qrserver.com/v1/create-qr-code/?data=' +"https://vidar-9e8ac.web.app/?dest="+ code + '&amp;size=200x200';
    $('#qr-canvas').attr('src', url);
}

function ecouteScan (uid){
  db.ref("/Users/"+uid+"/contact").on('value', (snapshot) => {
    if (drapeau==0){
      drapeau = 1;
    }else{
      if (snapshot.exists()) {
        
        cont = snapshot.val();
      
        db.ref("/Users/"+uid+"/contact").set(null);
        sessionStorage.setItem("destinataire",cont);
        window.location = "index2.html";
      }
    }

  });
}

//DEBUT

if (firebase.auth.currentUser==null && SessionCo == null){  //créé une session temporaire
  connecteAnonyme();  //session temporaire
}else{
  $(".open-button").addClass(".invisible")
}

var html5QrcodeScanner = new Html5QrcodeScanner("reader", { fps: 10, qrbox: 250 });
html5QrcodeScanner.render(onScanSuccess);
  
$("#vers_dis").on("click", function(event){
  envoieCode($("#destinataire-input").val());
  return false;
});

$("#btn-scan-qr").on("click", function(event){
  $("#reader").removeClass("invisible");
  $("#codeu").addClass("invisible");
});



