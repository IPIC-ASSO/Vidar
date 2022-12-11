var firebaseConfig = {
    apiKey: "AIzaSyBUb9qCgE0vdY7rqykD0T1O-I9x817TAhk",
    authDomain: "vidar-9e8ac.firebaseapp.com",
    databaseURL: "https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "vidar-9e8ac",
    storageBucket: "vidar-9e8ac.appspot.com",
    messagingSenderId: "276571176774",
    appId: "1:276571176774:web:725f1bbe89a6eb7097af47",

  };

  firebase.initializeApp(firebaseConfig);
  const auth = firebase.auth();
  const db = firebase.database();
  
  function inscrit(e){
      //e.preventDefault();
      const email = document.getElementById("e-mail-inscription");
      const mdp = document.getElementById("mot-de-passe-inscription");
      firebase.auth().createUserWithEmailAndPassword(email.value, mdp.value)
      .then((userCredential) => {
          // Signed in 
          const user = userCredential.user;
          db.ref("Users/" + user.uid).set({
              id:user.uid,
              imageURL:defaut,
              username:document.getElementById("pseudo")
            });
            sessionStorage.setItem("co",1);
            window.location = "index2.html";
      })
      .catch((error) => {
          const errorCode = error.code;
          const errorMessage = error.message;
          alert("inscription impossible "+errorCode)
          // ..
      })
  }
  
  function connecte(e){
      //e.preventDefault();
      const email = document.getElementById("e-mail");
      const mdp = document.getElementById("mot-de-passe");
      firebase.auth().signInWithEmailAndPassword(email.value, mdp.value)
      .then((userCredential) => {
          // Signed in 
          const user = userCredential.user;
          sessionStorage.setItem("co",1);
          window.location = "index2.html";

      })
      .catch((error) => {
          const errorCode = error.code;
          const errorMessage = error.message;
          alert("connexion impossible "+errorCode)
      });
  }
  
  function deconnecte(){
      firebase.auth().signOut(auth).then(() => {
          // Sign-out successful.
      }).catch((error) => {
          // An error happened.
      });
  }


jQuery(document).ready(function($){
var $form_modal = $('.user-modal'),
    $form_login = $form_modal.find('#login'),
    $form_signup = $form_modal.find('#signup'),
    $form_code = $form_modal.find('#code')
    $form_forgot_password = $form_modal.find('#reset-password'),
    $form_modal_tab = $('.switcher'),
    $tab_login = $form_modal_tab.children('li').eq(0).children('a'),
    $tab_signup = $form_modal_tab.children('li').eq(1).children('a'),
    $forgot_password_link = $form_login.find('.form-bottom-message a'),
    $back_to_login_link = $form_forgot_password.find('.form-bottom-message a'),
    $main_nav = $('.main-nav');
    $enr = $('.enr')

//open modal
$enr.on('click', function(event){

    if( $(event.target).is($main_nav) ) {
    // on mobile open the submenu
    $(this).children('ul').toggleClass('is-visible');
    } else {
    // on mobile close submenu
    $main_nav.children('ul').removeClass('is-visible');
    //show modal layer
    $form_modal.addClass('is-visible'); 
    //show the selected form
    ( $(event.target).is('.signup') ) ? signup_selected() : login_selected();
    }

});

//close modal
$('.user-modal').on('click', function(event){
    if( $(event.target).is($form_modal) || $(event.target).is('.close-form') ) {
    $form_modal.removeClass('is-visible');
    } 
});
//close modal when clicking the esc keyboard button
$(document).keyup(function(event){
    if(event.which=='27'){
        $form_modal.removeClass('is-visible');
    }
    });

//switch from a tab to another
$form_modal_tab.on('click', function(event) {
    event.preventDefault();
    ( $(event.target).is( $tab_login ) ) ? login_selected() : signup_selected();
});

//hide or show password
$('.hide-password').on('click', function(){
    var $this= $(this),
    $password_field = $this.prev('input');
    
    ( 'password' == $password_field.attr('type') ) ? $password_field.attr('type', 'text') : $password_field.attr('type', 'password');
    ( 'Afficher' == $this.text() ) ? $this.text('Cacher') : $this.text('Afficher');
    //focus and move cursor to the end of input field
    $password_field.putCursorAtEnd();
});

//show forgot-password form 
$forgot_password_link.on('click', function(event){
    event.preventDefault();
    forgot_password_selected();
});

//back to login from the forgot-password form
$back_to_login_link.on('click', function(event){
    event.preventDefault();
    login_selected();
});

function login_selected(){
    $form_login.addClass('is-selected');
    $form_signup.removeClass('is-selected');
    $form_forgot_password.removeClass('is-selected');
    $tab_login.addClass('selected');
    $tab_signup.removeClass('selected');
}

function signup_selected(){
    $form_login.removeClass('is-selected');
    $form_signup.addClass('is-selected');
    $form_forgot_password.removeClass('is-selected');
    $tab_login.removeClass('selected');
    $tab_signup.addClass('selected');
}

function forgot_password_selected(){
    $form_login.removeClass('is-selected');
    $form_signup.removeClass('is-selected');
    $form_forgot_password.addClass('is-selected');
}

$form_login.find('input[type="submit"]').on('click', function(event)
{
    event.preventDefault();
    connecte();
    //$form_login.find('input[type="email"]').toggleClass('has-error').next('span').toggleClass('is-visible');//message d'erreur
});
$form_signup.find('input[type="submit"]').on('click', function(event){
    event.preventDefault();
    inscrit();
    //$form_signup.find('input[type="email"]').toggleClass('has-error').next('span').toggleClass('is-visible');   //message d'erreur
});


});
  
  
  //credits https://css-tricks.com/snippets/jquery/move-cursor-to-end-of-textarea-or-input/
  jQuery.fn.putCursorAtEnd = function() {
    return this.each(function() {
        // If this function exists...
        if (this.setSelectionRange) {
            // ... then use it (Doesn't work in IE)
            // Double the length because Opera is inconsistent about whether a carriage return is one character or two. Sigh.
            var len = $(this).val().length * 2;
            this.setSelectionRange(len, len);
        } else {
          // ... otherwise replace the contents with itself
          // (Doesn't work in Google Chrome)
            $(this).val($(this).val());
        }
    });
  };
  