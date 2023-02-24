package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;

import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.speech.tts.TextToSpeech;
import android.speech.tts.Voice;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.helper.widget.MotionEffect;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.messaging.FirebaseMessaging;
import com.ipiccie.muetssages.adaptateur.MessagerAdapte;
import com.ipiccie.muetssages.client.Chat;
import com.ipiccie.muetssages.client.Discussion;
import com.ipiccie.muetssages.client.Utilisateur;
import com.ipiccie.muetssages.notifications.APIService;
import com.ipiccie.muetssages.notifications.Client;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

public class ActiviteDiscussion extends AppCompatActivity {

    private DatabaseReference reference;
    private List<Chat> listeDeChats;
    private RecyclerView recyclage;
    private HashMap<String, String> listeDeMessages;
    private TextToSpeech textToSpeech;
    APIService apiService;

    private static final String db = "https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_activite_discussion);


        EditText msg = findViewById(R.id.mon_message);
        DatabaseReference databaseReference;

        FirebaseUser fuser = FirebaseAuth.getInstance().getCurrentUser();
        String idUti = getIntent().getStringExtra("id");    // id interlocuteur
        String idDis = getIntent().getStringExtra("dis");    // id discussion
        boolean supr = getIntent().getBooleanExtra("supr",false);    // id discussion

        if (fuser == null || idUti==null || idDis == null){
            Toast.makeText(this,"Une erreur est survenue. Veuillez redémarrer l'application",Toast.LENGTH_LONG).show();
        }else{
            //affichage de tous les messages
            recyclage = findViewById(R.id.recyclage_de_messages);
            recyclage.setHasFixedSize(true);
            LinearLayoutManager manager = new LinearLayoutManager(this);
            manager.setStackFromEnd(true);
            recyclage.setLayoutManager(manager);
            Log.d(TAG, "onCreate: "+idDis);
            FirebaseDatabase.getInstance(db).getReference().child("Users").child(fuser.getUid()).child("contact").setValue(" ");
            reference = FirebaseDatabase.getInstance(db).getReference().child("Users").child(idUti);
            TextView nomUti = findViewById(R.id.utilisateur_conv_dis);
            ImageView imgUti = findViewById(R.id.image_profile_dis);
            reference.addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    Utilisateur uti = snapshot.getValue(Utilisateur.class);
                    assert uti != null;
                    nomUti.setText(uti.getUsername());
                    if (uti.getImageURL()!= null && uti.getImageURL().equals("defaut")){
                        imgUti.setImageResource(R.drawable.ic_baseline_account_circle_24);
                    }
                    postier(idDis);
                }
                @Override
                public void onCancelled(@NonNull DatabaseError error) {
                    //RàS
                }
            });
            String msgEnr = getIntent().getStringExtra("message");
            if (msgEnr != null && !Objects.equals(msgEnr, " ")&& !Objects.equals(msgEnr, "")){
                envoyerMessage(fuser.getUid(),idDis,msgEnr);
            }
            if (!supr){
                //init messages
                databaseReference = FirebaseDatabase.getInstance(db).getReference().child("Users").child(fuser.getUid()).child("messages");
                databaseReference.addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        listeDeMessages = new HashMap<>();
                        Log.d(TAG, "onDataChange: " + snapshot.getValue());
                        if (snapshot.getValue() != null) {
                            listeDeMessages = (HashMap<String, String>) snapshot.getValue();
                        }
                        listeMessages();
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        Log.d(TAG, "onCancelled: " + error);
                    }
                });

                //init btn envoyer message
                findViewById(R.id.envoyer_message).setOnClickListener(v->{
                    if (!msg.getText().toString().equals(""))envoyerMessage(fuser.getUid(),idDis,msg.getText().toString());
                    msg.setText("");
                });
            }else{
                findViewById(R.id.redacteur).setVisibility(View.GONE);
                findViewById(R.id.conv_terminée).setVisibility(View.VISIBLE);
            }
        }
        WindowInsetsControllerCompat windowInsetsController =
                WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        windowInsetsController.hide(WindowInsetsCompat.Type.systemBars());
        // Configure the behavior of the hidden system bars.
        windowInsetsController.setSystemBarsBehavior(
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_BARS_BY_SWIPE
        );
        textToSpeech = new TextToSpeech(this, status -> maVoix(textToSpeech),"com.google.android.tts");

        findViewById(R.id.supre_conv).setOnClickListener(v-> new AlertDialog.Builder(this)
                .setTitle("Supprimer la conversation")
                .setMessage("Voulez vous vraiment supprimer cette conversation?\nCette action est irréversible")
                .setNegativeButton("Annuler", (dialogInterface, i) -> dialogInterface.dismiss())
                .setPositiveButton("Supprimer", (dialogInterface, i) -> {
                    DatabaseReference databaseReference3 = FirebaseDatabase.getInstance().getReference().child("ListeChats").child(idDis);
                    databaseReference3.addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot snapshot) {
                            Discussion discussion = snapshot.getValue(Discussion.class);
                            if (discussion!= null && discussion.getSupr()!=null) {
                                databaseReference3.setValue(null);
                                databaseReference3.getRoot().child("Chats").child(idDis).setValue(null);
                            }
                            else databaseReference3.child("supr").setValue(Objects.requireNonNull(fuser).getUid());
                            onBackPressed();
                        }
                        @Override
                        public void onCancelled(@NonNull DatabaseError error) {
                            //RàS
                        }
                    });
                })
                .show());


        apiService = Client.getClient("https://fcm.googleapis.com/").create(APIService.class);
        verifToken();

        ActionBar ab = (this.getSupportActionBar());
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
    }



    public void notif(String sujet){
        /*Notification notification = new Notification.Builder().setContentTitle("2 new messages with " + sender.toString())
                .setContentText(sujet)
                .setSmallIcon(R.drawable.ic_baseline_message_24)
                .setLargeIcon()
                .setStyle(new Notification.MessagingStyle(resources.getString(R.string.reply_name))
                        .addMessage(messages[0].getText(), messages[0].getTime(), messages[0].getSender())
                        .addMessage(messages[1].getText(), messages[1].getTime(), messages[1].getSender()))
                .build();*/
    }

    public void envoyerMessage(String envoyeur, String idDiscussion, String message){
        Log.d(TAG, "envoyerMessage: "+"OKOKHOK");
        DatabaseReference reference2 = FirebaseDatabase.getInstance(db).getReference();
        HashMap<String, String> carteDeH = new HashMap<>();
        carteDeH.put("envoyeur",envoyeur);
        carteDeH.put("message",message);
        reference2.child("Chats").child(idDiscussion).child(String.valueOf(System.currentTimeMillis())).setValue(carteDeH);
    }

    public void postier(String idDiscussion){
        listeDeChats = new ArrayList<>();
        reference = FirebaseDatabase.getInstance(db).getReference().child("Chats").child(idDiscussion);
        reference.addValueEventListener(ecouteNouvMessages);
    }

    private final ValueEventListener ecouteNouvMessages = new ValueEventListener() {
        @Override
        public void onDataChange(@NonNull DataSnapshot snapshot) {
            listeDeChats.clear();
            for (DataSnapshot snap:snapshot.getChildren()){
                Chat chaton = snap.getValue(Chat.class);
                listeDeChats.add(chaton);
            }
            MessagerAdapte messagerAdapte = new MessagerAdapte(ActiviteDiscussion.this, listeDeChats);
            recyclage.setAdapter(messagerAdapte);
        }

        @Override
        public void onCancelled(@NonNull DatabaseError error) {
            // RàS
        }
    };

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            if (reference!=null) reference.removeEventListener(ecouteNouvMessages);
            finish();
            onBackPressed();
            return true;
        }
        return false;
    }



    public void popUp(String texte){
        AlertDialog.Builder constr = new AlertDialog.Builder(this);
        constr.setTitle("Actions sur le message : "+texte);
        View vue = View.inflate(this, R.layout.pop_up_message,null);
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        DatabaseReference databaseReference = null;
        if (firebaseUser != null) {
            databaseReference = FirebaseDatabase.getInstance(db).getReference().child("Users").child(firebaseUser.getUid()).child("messages");
        }
        constr.setView(vue);
        AlertDialog show = constr.show();
        DatabaseReference finalDatabaseReference = databaseReference;
        vue.findViewById(R.id.pop_enr_mes).setOnClickListener(v->{
            if (finalDatabaseReference != null) {
                finalDatabaseReference.child(texte.substring(0,Math.min(20, texte.length()))).removeValue();
                finalDatabaseReference.child(texte.substring(0,Math.min(20, texte.length()))).setValue(texte);
                Toast.makeText(this, "Enregistré !", Toast.LENGTH_SHORT).show();
            }else{
                Toast.makeText(this, "Enregistrement impossible", Toast.LENGTH_SHORT).show();
            }
            show.dismiss();
        });
        vue.findViewById(R.id.pop_lit_mes).setOnClickListener(v->{
            textToSpeech.speak(texte,TextToSpeech.QUEUE_FLUSH,null, null);
            Toast.makeText(this,"Lecture en cours",Toast.LENGTH_SHORT).show();
            show.dismiss();
        });
        show.show();
    }

    public void listeMessages(){
        String[] listeMsg = listeDeMessages.keySet().toArray(new String[0]);
        EditText msg = findViewById(R.id.mon_message);
        findViewById(R.id.liste_messages_enr).setOnClickListener(w->{
            AlertDialog.Builder constr= new AlertDialog.Builder(this);
            constr.setTitle("Message à afficher");
            constr.setItems(listeMsg, (dialog, which) -> msg.setText(String.format("%s%s",msg.getText().toString(),listeDeMessages.get(listeMsg[which]))));
            constr.show();
            });
    }

    private void verifToken(){
        FirebaseMessaging.getInstance().getToken()
                .addOnCompleteListener(task -> {
                    if (!task.isSuccessful()) {
                        Log.w(MotionEffect.TAG, "Fetching FCM registration token failed", task.getException());
                        return;
                    }
                    String token = task.getResult();
                    DatabaseReference databaseReference = FirebaseDatabase.getInstance(db).getReference().child("Users").child(Objects.requireNonNull(FirebaseAuth.getInstance().getCurrentUser()).getUid()).child("tokens");
                    databaseReference.addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot snapshot) {
                            String tok = snapshot.getValue(String.class);
                            if(tok!= null){
                                String[] tokens = tok.split(",");
                                if (!Arrays.asList(tokens).contains(token)){
                                    StringBuilder str = new StringBuilder();
                                    for (String s:tokens)str.append(s).append(",");
                                    str.append(token);
                                    databaseReference.setValue(str.toString());
                                }
                            }else{
                                databaseReference.setValue(token);
                            }
                        }

                        @Override
                        public void onCancelled(@NonNull DatabaseError error) {
                            //RàS
                        }
                    });
                });
    }

    public void maVoix(TextToSpeech tts){
        SharedPreferences pref = this.getSharedPreferences("prefs",Context.MODE_PRIVATE);
        String voii = pref.getString("voix","fr-FR-language");
        Log.d(TAG, "maVoix: "+voii);
        textToSpeech.setVoice(tts.getDefaultVoice());
        for (Voice tmpVoice : tts.getVoices()) {
            if (tmpVoice.getName().equals(voii)) {
                textToSpeech.setVoice(tmpVoice);
                Log.d(TAG, "maVoix: :))))))");
            }
        }
        textToSpeech.setSpeechRate(1.3F);
    }
    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Intent intention = new Intent(getBaseContext(), MainActivity.class);
        intention.putExtra("disc","go");
        startActivity(intention);
        Log.d(TAG, "onBackPressed: OKOK");
    }
}