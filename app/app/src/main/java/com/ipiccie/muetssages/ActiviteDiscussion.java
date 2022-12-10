package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;

import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.LayoutInflater;
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
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.ipiccie.muetssages.adaptateur.MessagerAdapte;
import com.ipiccie.muetssages.client.Chat;
import com.ipiccie.muetssages.client.Utilisateur;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

public class ActiviteDiscussion extends AppCompatActivity {

    private DatabaseReference reference;
    private FirebaseUser fuser;
    private List<Chat> listeDeChats;
    private RecyclerView recyclage;
    private HashMap<String, String> listeDeMessages;

    private String dB = "https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app";

    /*@Override
    public void onNewToken(@NonNull String token) {
        Log.d(TAG, "Refreshed token: " + token);

        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // FCM registration token to your app server.
        sendRegistrationToServer(token);
    }*/

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_activite_discussion);

        // This callback will only be called when MyFragment is at least Started.
        OnBackPressedCallback callback = new OnBackPressedCallback(true /* enabled by default */) {
            @Override
            public void handleOnBackPressed() {
                this.remove();
                Intent intention = new Intent(getBaseContext(), MainActivity.class);
                intention.putExtra("disc","go");
                startActivity(intention);
            }
        };
        getOnBackPressedDispatcher().addCallback(this, callback);

        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        listeDeMessages = new HashMap<>();
        EditText msg = findViewById(R.id.mon_message);
        DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid()).child("messages");
        databaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                listeDeMessages.clear();
                Log.d(TAG, "onDataChange: "+snapshot.getValue());
                if (snapshot.getValue()!= null){
                    listeDeMessages = (HashMap<String, String>) snapshot.getValue();
                }
                String[] listeMsg = listeDeMessages.keySet().toArray(new String[0]);

                findViewById(R.id.liste_messages_enr).setOnClickListener(w->{
                    AlertDialog.Builder constr= new AlertDialog.Builder(getApplicationContext());
                    constr.setTitle("Message à afficher");
                    constr.setMessage("BjR");
                    //constr.setItems(listeMsg, (dialog, which) -> msg.setText(msg.getText().toString() + listeDeMessages.get(listeMsg[which])));
                    constr.show();
                });

            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });




        Log.d(TAG, "onCreate: "+listeDeMessages);
        fuser = FirebaseAuth.getInstance().getCurrentUser();
        if (fuser == null){
            Toast.makeText(this,"Une erreur est survenue. Veuillez redémarer l'application",Toast.LENGTH_LONG).show();
        }else{
            recyclage = findViewById(R.id.recyclage_de_messages);
            recyclage.setHasFixedSize(true);
            LinearLayoutManager manager = new LinearLayoutManager(this);
            manager.setStackFromEnd(true);
            recyclage.setLayoutManager(manager);
            String idUti = getIntent().getStringExtra("id");    // id interlocuteur
            String idDis = getIntent().getStringExtra("dis");    // id discussion
            Log.d(TAG, "onCreate: "+idDis);
            reference = FirebaseDatabase.getInstance(dB).getReference().child("Users").child(idUti);
            reference.child("contact").setValue(" ");
            TextView nomUti = findViewById(R.id.utilisateur_conv_dis);
            ImageView imgUti = findViewById(R.id.image_profile_dis);
            reference.addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    Utilisateur uti = snapshot.getValue(Utilisateur.class);
                    assert uti != null;
                    nomUti.setText(uti.getUsername());
                    if (uti.getImageURL()!= null && uti.getImageURL().equals("defaut")){
                        imgUti.setImageResource(R.drawable.ic_launcher_foreground);
                    }
                    postier(fuser.getUid(),idUti, idDis);
                }
                @Override
                public void onCancelled(@NonNull DatabaseError error) {
                    //RàS
                }
            });
            if (getIntent().getStringExtra("message")!= null){
                envoyerMessage(fuser.getUid(),idDis,getIntent().getStringExtra("message"));
            }
            findViewById(R.id.envoyer_message).setOnClickListener(v->{
                if (!msg.getText().toString().equals(""))envoyerMessage(fuser.getUid(),idDis,msg.getText().toString());
                msg.setText("");
            });
        }
        /*ActionBar ab = (this.getSupportActionBar());
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }*/
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

    private void sendRegistrationToServer(String token) {
        // TODO: Implement this method to send token to your app server.
    }

    public void envoyerMessage(String envoyeur, String idDiscussion, String message){
        Log.d(TAG, "envoyerMessage: "+"OKOKHOK");
        DatabaseReference reference2 = FirebaseDatabase.getInstance(dB).getReference();
        HashMap<String, String> carteDeH = new HashMap<>();
        carteDeH.put("envoyeur",envoyeur);
        carteDeH.put("message",message);
        reference2.child("Chats").child(idDiscussion).child(String.valueOf(System.currentTimeMillis())).setValue(carteDeH);
    }

    public void postier(String mId, String uId, String idDiscussion){
        listeDeChats = new ArrayList<>();
        reference = FirebaseDatabase.getInstance(dB).getReference().child("Chats").child(idDiscussion);
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
        switch (item.getItemId()) {
            case android.R.id.home:
                reference.removeEventListener(ecouteNouvMessages);
                finish();
                startActivity(new Intent(this, MainActivity.class));
                return true;
            default:
                return false;
        }
    }

    public void popUp(String texte){
        AlertDialog.Builder constr = new AlertDialog.Builder(this);
        constr.setTitle("Actions sur le message");
        View vue = View.inflate(this, R.layout.pop_up_message,null);
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid()).child("messages");
        constr.setView(vue);
        AlertDialog show = constr.show();
        vue.findViewById(R.id.pop_enr_mes).setOnClickListener(v->{
            databaseReference.child(texte.substring(0,Math.min(20, texte.length()))).removeValue();
            databaseReference.child(texte.substring(0,Math.min(20, texte.length()))).setValue(texte);
            Toast.makeText(this, "Enregistré !", Toast.LENGTH_SHORT).show();
            show.dismiss();
        });
        vue.findViewById(R.id.pop_lit_mes).setOnClickListener(v->{
            TextToSpeech textToSpeech = new TextToSpeech(this, status -> {});
            textToSpeech.setLanguage(Locale.FRANCE);
            textToSpeech.setSpeechRate(1.3F);
            textToSpeech.speak(texte, TextToSpeech.QUEUE_FLUSH,null);
            Toast.makeText(this,"Lecture en cours",Toast.LENGTH_SHORT).show();
            show.dismiss();
        });
        show.show();
    }
}