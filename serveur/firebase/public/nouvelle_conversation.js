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

async function getMedia(constraints) {
  let stream = null;

  try {
    stream = await navigator.mediaDevices.getUserMedia(constraints);
    /* use the stream */
  } catch (err) {
    alert('impossible de scanner le QR-code');
  }
}

function hasGetUserMedia() {
  return !!(navigator.getUserMedia || navigator.webkitGetUserMedia ||
          navigator.mozGetUserMedia || navigator.msGetUserMedia);
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
  } else {//deco
    alert("Adieu :.(");
  }
});


var utilisateur;
var qrcode = window.qrcode;

const video = document.createElement("video");
const canvasElement = document.getElementById("qr-canvas");

const qrResult = document.getElementById("qr-result");
const outputData = document.getElementById("outputData");
const btnScanQR = document.getElementById("btn-scan-qr");

let scanning = false;

if (firebase.auth.currentUser==null && SessionCo == null){  //créé une session temporaire
  connecteAnonyme();  //session temporaire
}else{
  $(".open-button").addClass(".invisible")
}

qrcode.callback = (res) => {
    if (res) {
      sessionStorage.setItem("destinataire",res);
      
      scanning = false;
  
      video.srcObject.getTracks().forEach(track => {
        track.stop();
      });
  
      qrResult.hidden = false;
      btnScanQR.hidden = false;
      canvasElement.hidden = true;
      window.location = "index2.html";
    }
  };

btnScanQR.onclick = () =>{
  if (hasGetUserMedia()) {
    navigator.mediaDevices
    .getUserMedia({ video: { facingMode: "environment" } })
    .then(function(stream) {
        scanning = true;
        qrResult.hidden = true;
        btnScanQR.hidden = true;
        canvasElement.hidden = false;
        video.setAttribute("playsinline", true); // required to tell iOS safari we don't want fullscreen
        video.srcObject = stream;
        video.play();
        tick();
        scan();
}).catch(function(err) {
  alert(err);
});
  } else {
    alert('navigateur incompatible');
  }
}


function tick() {
    canvasElement.height = video.videoHeight;
    canvasElement.width = video.videoWidth;
    canvas.drawImage(video, 0, 0, canvasElement.width, canvasElement.height);
  
    scanning && requestAnimationFrame(tick);
  }
  
function scan() {
    try {
        qrcode.decode();
    } catch (e) {
        setTimeout(scan, 300);
    }
}

function envoieCode(e){
    e.preventDefault();
    alert ("ok");
    sessionStorage.setItem("destinataire",document.getElementById("destinataire-input").value+"");
    window.location = "index2.html";
}

function generateBarCode(code) 
{
    var nric = $('#text').val();
    var url = 'https://api.qrserver.com/v1/create-qr-code/?data=' + code + '&amp;size=200x200';
    $('#qr-canvas').attr('src', url);
}
  

document.getElementById("code").addEventListener("submit", envoieCode);



