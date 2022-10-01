package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.play.core.tasks.OnCompleteListener;
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
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ActiviteDiscussion extends AppCompatActivity {

    private Socket clientSocket;
    private BufferedReader entre;
    private PrintWriter sort;
    private DatabaseReference reference;
    private FirebaseUser fuser;
    private MessagerAdapte messagerAdapte;
    private List<Chat> listeDeChats;
    private RecyclerView recyclage;

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
        SharedPreferences prefs =this.getBaseContext().getSharedPreferences("classes", Context.MODE_PRIVATE);//liste des intitulés et message associé
        EditText msg = findViewById(R.id.mon_message);
        String[] listeMsg =prefs.getAll().keySet().toArray(new String[0]);
        findViewById(R.id.liste_messages_enr).setOnClickListener(w->new MaterialAlertDialogBuilder(this).setTitle("Message à afficher").setItems(listeMsg, (dialog, which) -> msg.setText(msg.getText().toString()+prefs.getString(listeMsg[which],"oups"))).show());
        fuser = FirebaseAuth.getInstance().getCurrentUser();
        if (fuser == null){
            Toast.makeText(this,"Une erreur est survenue. Veuillez redémarer l'application",Toast.LENGTH_LONG).show();
        }else{
            recyclage = findViewById(R.id.recyclage_de_messages);
            recyclage.setHasFixedSize(true);
            LinearLayoutManager manager = new LinearLayoutManager(this);
            manager.setStackFromEnd(true);
            recyclage.setLayoutManager(manager);
            String idUti = getIntent().getStringExtra("id");
            reference = FirebaseDatabase.getInstance(dB).getReference().child("Users").child(idUti);
            TextView nomUti = findViewById(R.id.utilisateur_conv_dis);
            ImageView imgUti = findViewById(R.id.image_profile_dis);
            reference.addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    Utilisateur uti = snapshot.getValue(Utilisateur.class);
                    assert uti != null;
                    nomUti.setText(uti.getUsername());
                    if (uti.getImageURL().equals("defaut")){
                        imgUti.setImageResource(R.drawable.ic_launcher_foreground);
                    }
                    postier(fuser.getUid(),idUti);
                }
                @Override
                public void onCancelled(@NonNull DatabaseError error) {
                    //RàS
                }
            });
            if (getIntent().getStringExtra("message")!= null){
                envoyerMessage(fuser.getUid(),idUti,getIntent().getStringExtra("message"));
            }
            findViewById(R.id.envoyer_message).setOnClickListener(v->{
                if (!msg.getText().toString().equals(""))envoyerMessage(fuser.getUid(),idUti,msg.getText().toString());
                msg.setText("");
            });
        }
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

    private void sendRegistrationToServer(String token) {
        // TODO: Implement this method to send token to your app server.
    }

    public void envoyerMessage(String envoyeur, String destinataire, String message){
        DatabaseReference reference2 = FirebaseDatabase.getInstance(dB).getReference();
        HashMap<String, String> carteDeH = new HashMap<>();
        carteDeH.put("envoyeur",envoyeur);
        carteDeH.put("destinataire",destinataire);
        carteDeH.put("message",message);
        reference2.child("Chats").push().setValue(carteDeH);
    }

    public void postier(String mId, String uId){
        listeDeChats = new ArrayList<>();
        reference = FirebaseDatabase.getInstance(dB).getReference().child("Chats");
        reference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                listeDeChats.clear();
                for (DataSnapshot snap:snapshot.getChildren()){
                    Chat chaton = snap.getValue(Chat.class);
                    if (chaton!=null && ((chaton.getDestinataire().equals(mId)&& chaton.getEnvoyeur().equals(uId))||(chaton.getDestinataire().equals(uId)&& chaton.getEnvoyeur().equals(mId)))){
                        listeDeChats.add(chaton);
                    }
                }
                messagerAdapte = new MessagerAdapte(ActiviteDiscussion.this, listeDeChats);
                recyclage.setAdapter(messagerAdapte);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                startActivity(new Intent(this, MainActivity.class));
                finish();
                return true;
            default:
                return false;
        }
    }
}