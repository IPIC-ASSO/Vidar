package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.speech.tts.Voice;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.ipiccie.muetssages.client.Utilisateur;

import java.util.Locale;

import androidmads.library.qrgenearator.QRGContents;
import androidmads.library.qrgenearator.QRGEncoder;


public class LanceDiscussion extends Fragment {

    private int drapeau = 0;
    private TextToSpeech textToSpeech;

    public LanceDiscussion() {
        // Required empty public constructor
    }


    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ActionBar ab = ((AppCompatActivity) requireActivity()).getSupportActionBar();
        ImageView image = view.findViewById(R.id.qr_code);
        textToSpeech = new TextToSpeech(this.requireContext(), status -> maVoix(textToSpeech),"com.google.android.tts");
        TextView msg = view.findViewById(R.id.message_haut_Qr);
        if (getArguments() != null) {
            msg.setText(getArguments().getString("msg_ecrit"," "));
        }
        view.findViewById(R.id.lire_texte).setOnClickListener(v->{
            textToSpeech.speak(getArguments().getString("msg_lu"),TextToSpeech.QUEUE_FLUSH,null,null);
            Toast.makeText(this.getContext(),"Lecture en cours",Toast.LENGTH_SHORT).show();
        });


        DisplayMetrics displayMetrics = new DisplayMetrics();
        this.requireActivity().getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        int width = displayMetrics.widthPixels;
        int height = displayMetrics.heightPixels;
        // Initialisation du QR code, avec comme valeur l'uid.
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        if (firebaseUser!=null){
            TextView instructions = view.findViewById(R.id.instruction_scan);
            instructions.setText(String.format("%s%s", getString(R.string.txt_infos_scan), firebaseUser.getUid()));
            QRGEncoder qrgEncoder = new QRGEncoder("https://vidar-9e8ac.web.app/?dest="+firebaseUser.getUid(), null, QRGContents.Type.TEXT,Math.min(height,width));
            image.setImageBitmap(qrgEncoder.getBitmap());
            DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid());
            databaseReference.addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    if (drapeau == 0){// 1ère lecture
                        drapeau = 1;
                    }else{
                        Utilisateur uti = snapshot.getValue(Utilisateur.class);
                        if (uti != null) {
                            Intent intention = new Intent(requireContext(),ActiviteDiscussion.class);
                            Log.d(TAG, "onDataChange: "+snapshot.getValue());
                            intention.putExtra("id", uti.getContact());    //identifiant interlocuteur
                            intention.putExtra("dis", uti.getContact()+firebaseUser.getUid());   //identifiant discussion
                            intention.putExtra("message", getArguments() != null ? getArguments().getString("msg_debut", "Bonjour") : null);    //message de départ
                            databaseReference.removeEventListener(this);
                            startActivity(intention);
                        }
                    }
                }

                @Override
                public void onCancelled(@NonNull DatabaseError error) {
                    //RàS
                }
            });
        }else{
            Toast.makeText(this.getContext(),"Erreur critique, veuillez redémarer l'application ou contacter le service d'assistance",Toast.LENGTH_LONG).show();
        }

        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
    }

    public void maVoix(TextToSpeech tts){
        SharedPreferences pref = this.requireActivity().getSharedPreferences("prefs", Context.MODE_PRIVATE);
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
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_lance_discussion, container, false);
    }
}