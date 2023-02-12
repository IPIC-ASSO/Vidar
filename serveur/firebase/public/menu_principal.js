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
var listemsg;
var btnselect;

function detectMob() {
  return ( ( window.innerWidth <= 800 ) || ( window.innerHeight <= 600 ) );
}

firebase.auth().onAuthStateChanged((user) => {  //écoute le changement de statut de l'utilisateur
    if (user) {//co
      utilisateur = user;
      initmsg();
      initconv();
    } else {//deco
    }
  });

function initmsg(){
    chemin2 = "/Users/"+utilisateur.uid+"/messages"
    const fetchChat = db.ref(chemin2); 
    //écoute l'arrivée de nouveaux messages
    fetchChat.on("child_added", function(snapshot) {
      listemsg = snapshot;
      const message = `<li class=msg_boite id="${listemsg.key}">${listemsg.key}</li>`;
      
      // ajout de la balise dans la page
      document.getElementById("messages").innerHTML += message;
    });
    fetchChat.on("child_removed",function(childSnapshot){
      document.getElementById("messages").innerHTML=null;
      initmsg()
    });
}

function initconv(){
  chemin = "/ListeChats"
  
  const fetchChat = db.ref(chemin); 
  //écoute l'arrivée de nouveaux messages
  fetchChat.on("child_added", function (snapshot) {
    const conver = snapshot.val();
    if (conver.utilisateur1== utilisateur.uid || conver.utilisateur2== utilisateur.uid){
      const uti1 = conver.utilisateur1
      const uti2 = conver.utilisateur2
      utilisateur.uid === conver.utilisateur1 ? chemin = "/Users/"+uti2+"/username" : chemin = "/Users/"+uti1+"/username"
      db.ref(chemin).get().then((snapshot) => {
        var contact = "Inconnu au bataillon";
        if (snapshot.exists()) {
          contact = snapshot.val()
        }
        const conv = `<li class=msg_boite id=${
        utilisateur.uid === uti1 ? uti2 : uti1}>${contact}</li>`
        // ajout de la balise dans la page
        document.getElementById("conversations").innerHTML += conv;
      });
    }
  });
  fetchChat.on("child_removed",function(childSnapshot){
    document.getElementById("conversations").innerHTML=null;
    initconv()
  });
}

function switchfen (affiche) {
  if (detectMob()){
    if (affiche){
      $("#m_b_msg").removeClass("invisible");
      $("#lsmsg").addClass("invisible");
      $("#retour").removeClass("invisible");
    }else{
      $("#m_b_msg").addClass("invisible");
      $("#lsmsg").removeClass("invisible");
      $("#retour").addClass("invisible");
      if (btnselect!=null){
        btnselect.remove('clique');
      }
      $("#nouv_demo").addClass("invisible")
    }
  }
}

/* Set the width of the side navigation to 250px */
function openNav() {
  document.getElementById("maNavDeCote").style.width = "250px";
  document.getElementById("main").style.opacity = "50%";
  var dimmer = $('.noirceur');
  dimmer.show();
}

/* Set the width of the side navigation to 0 */
function closeNav() {
  document.getElementById("maNavDeCote").style.width = "0";
  document.getElementById("main").style.opacity = "100%";
  var dimmer = $('.noirceur');
  dimmer.hide();
} 

function conf_deco(){
  document.getElementById('conf_deco').style.display='block';
}


//--------DEBUT----------\\

const SessionCo = sessionStorage.getItem("co")

if (firebase.auth.currentUser==null && SessionCo == null){  //pb co
  //TODO: afficher chargement
}

if (detectMob()){
  $("#m_b_msg").addClass("invisible");
  switchfen(false);
}

jQuery(document).ready(function($){
  $("#messages").on("click", ".msg_boite", function(event){
    if (btnselect!=null){
      btnselect.remove('clique');
    }
    switchfen(true);
    btnselect = this.classList;
    btnselect.add('clique');
    $("#nouv_demo").addClass("invisible")
    $("#charge").removeClass("invisible");
    $("#msg_defaut").addClass("invisible");
    $("#corps").addClass("invisible");
    const tete = this.textContent
    $("#en_tete").val(tete);
    db.ref("Users/"+utilisateur.uid+"/messages/"+tete).get().then((snapshot) => {
      if (snapshot.exists()) {
        $("#corps").val(snapshot.val());
      }
      $("#charge").addClass("invisible");
      $("#corps").removeClass("invisible");
    });
    $("#editeur").removeClass("invisible");
  });

  $("#conversations").on("click", ".msg_boite", function(event){
    if (btnselect!=null){
      btnselect.remove('clique');
    }
    var btn = this;
    sessionStorage.setItem("destinataire",$(btn).attr('id'));
    switchfen(true);
    btnselect = this.classList;
    btnselect.add('clique');
    var iframe = `<iframe src="/index2.html" width="100%" height="100%" frameBorder="0"></iframe>`;
    $("#charge").removeClass("invisible");
    $("#msg_defaut_conv").addClass("invisible");
    $("#interface_conv").empty();
    $("#interface_conv").append (iframe);
    $("#interface_conv").removeClass("invisible");
  });

  $("#nouv_conv").click(function(event){
    if (btnselect!=null){
      btnselect.remove('clique');
    }
    switchfen(true);
    btnselect = this.classList;
    btnselect.add('clique');
    var iframe = `<iframe src="/nouvelle_conversation.html" width="100%" height="100%" id="emb_nouv" frameBorder="0"></iframe>`;
    $("#charge").removeClass("invisible");
    $("#msg_defaut_conv").addClass("invisible");
    $("#interface_conv").removeClass("invisible");
    $("#interface_conv").empty();
    $("#interface_conv").append (iframe);
  })


  $("#btn_msg").on("click", function(event){
    if (btnselect!=null){
      btnselect.remove('clique');
    }
    $("#btn_msg").addClass("selection");
    $("#btn_conv").removeClass("selection");
    $("#messages").removeClass("invisible");
    $("#conversations").addClass("invisible");
    $("#nouv_msg").removeClass("invisible");
    $("#nouv_conv").addClass("invisible");
    $("#msg_defaut").removeClass("invisible");
    $("#msg_defaut_conv").addClass("invisible");
    $("#interface_conv").addClass("invisible");

  })
  $("#btn_conv").on("click", function(event){
    if (btnselect!=null){
      btnselect.remove('clique');
    }
    $("#btn_msg").removeClass("selection");
    $("#btn_conv").addClass("selection");
    $("#messages").addClass("invisible");
    $("#conversations").removeClass("invisible");
    $("#nouv_msg").addClass("invisible");
    $("#nouv_conv").removeClass("invisible");
    $("#msg_defaut").addClass("invisible");
    $("#msg_defaut_conv").removeClass("invisible");
    $("#editeur").addClass("invisible");
  })
  $("#enr").click(function(event){
    const tete = $("#en_tete").val();
    const chem = "Users/"+utilisateur.uid+"/messages/"+tete;
    const corps = $("#corps").val();
    var notif = document.getElementById("snackbar");
    if(corps!="" && tete!=""){
      $("#nouv_demo").addClass("invisible")
      db.ref(chem).set(corps,(error)=>{
        if(error){
          notif.textContent="Une erreur est survenue";
        }else{
          notif.textContent="Enregistré !"
        }
        notif.className = "show";
        $("#msg_defaut").removeClass("invisible");
        $("#editeur").addClass("invisible");
        if (btnselect!=null){
          btnselect.remove('clique');
        }
        switchfen(false);
        setTimeout(function(){ notif.className = notif.className.replace("show", ""); }, 3000);
      });
    }else if (corps ==""){
      notif.textContent="Veuillez saisir un message";
      notif.className = "show";
      switchfen(false);
      setTimeout(function(){ notif.className = notif.className.replace("show", ""); }, 3000);
    }else if(tete ==""){
      notif.textContent="Veuillez entrer un en-tête";
      notif.className = "show";
      switchfen(false);
      setTimeout(function(){ notif.className = notif.className.replace("show", ""); }, 3000);
    }
  });

  $("#supr").click(function(event){
    $("#nouv_demo").addClass("invisible")
    const tete = $("#en_tete").val();
    const chem = "Users/"+utilisateur.uid+"/messages/"+tete;
    db.ref(chem).set(null,(error)=>{
      var notif = document.getElementById("snackbar");
      if(error){
        notif.textContent="Une erreur est survenue";
      }else{
        notif.textContent="Supprimé!";
      }
      notif.className = "show";
      $("#msg_defaut").removeClass("invisible");
      $("#editeur").addClass("invisible");
      if (btnselect!=null){
        btnselect.remove('clique');
      }
      switchfen(false);
      setTimeout(function(){ notif.className = notif.className.replace("show", ""); }, 3000);
    })});

    $("#nouv_msg").click(function(event){
      $("#msg_defaut").addClass("invisible");
      $("#nouv_demo").removeClass("invisible")
      $("#editeur").removeClass("invisible");
      $("#en_tete").val("");
      $("#corps").val("");
      if (btnselect!=null){
        btnselect.remove('clique');
      }
      switchfen(true);
      
    })

    $("#menu").click(function(event){
      openNav();
    });

    $("#menu2").click(function(event){
      openNav();
    });

    $("#deco").click(function(event){
      document.getElementById('conf_deco').style.display='block'
    });

    $("#vrai_deco").click(function(event){
      firebase.auth().signOut().then(() => {
        sessionStorage.setItem("co",0);
        sessionStorage.setItem("destinataire",0);
        window.location = "authentification.html";
      }).catch((error) => {
        var notif = document.getElementById("snackbar");
        notif.textContent="Une erreur est survenue";
        setTimeout(function(){ notif.className = notif.className.replace("show", ""); }, 3000);
      });
    })

    $("#retour").click(function(event){
      switchfen(false);
    })
    
    // confirmation deco
  var modal = document.getElementById('conf_deco');

  // When the user clicks anywhere outside of the modal, close it
  window.onclick = function(event) {
    if (event.target == modal) {
      modal.style.display = "none";
    }
  }
});
