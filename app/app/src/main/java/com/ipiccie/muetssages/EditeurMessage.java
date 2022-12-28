package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.text.InputType;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.Locale;
import java.util.Objects;


public class EditeurMessage extends Fragment {

    public EditeurMessage() {
        // Required empty public constructor
    }


    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        ActionBar ab = ((AppCompatActivity) requireActivity()).getSupportActionBar();
        // This callback will only be called when MyFragment is at least Started.
        OnBackPressedCallback callback = new OnBackPressedCallback(true /* enabled by default */) {
            @Override
            public void handleOnBackPressed() {
                assert getParentFragment() != null;
                findNavController(getParentFragment()).navigate(R.id.action_editeurMessage_to_listeMessages);
                this.remove();
            }
        };
        requireActivity().getOnBackPressedDispatcher().addCallback(getViewLifecycleOwner(), callback);

        String intitule;        //message par défaut, ne devrait jamais s'afficher...
        String corpsMessage;
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        EditText inti = view.findViewById(R.id.intitule);   //titre du message
        EditText msg = view.findViewById(R.id.texte_message);       //corps du message
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
        if (getArguments() != null &&!Objects.equals(getArguments().getString("intitulé"), "inconnu au bataillon")) {
            intitule = getArguments().getString("intitulé");
            corpsMessage = getArguments().getString("message");
            if (Objects.equals(intitule, "message par defaut")){
                inti.setInputType(InputType.TYPE_NULL); //message par défaut => intitulé non modifiable
                inti.setOnClickListener(v-> Toast.makeText(this.getContext(),"L'en-tête de ce message n'est pas modifiable",Toast.LENGTH_SHORT).show());
            }
            inti.setText(intitule);
            msg.setText(corpsMessage);
        }
        DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(Objects.requireNonNull(firebaseUser).getUid()).child("messages");
        view.findViewById(R.id.enregistre_msg).setOnClickListener(v->{
            if(!inti.getText().toString().equals("") && !msg.getText().toString().equals("")){
                databaseReference.child(inti.getText().toString()).removeValue();
                databaseReference.child(inti.getText().toString()).setValue(msg.getText().toString());
                callback.remove();
                findNavController(this).navigate(R.id.action_editeurMessage_to_listeMessages);
            }else{
                Toast.makeText(this.getContext(),"Veuillez remplir tous les champs",Toast.LENGTH_SHORT).show();
            }
        });
        view.findViewById(R.id.supr_msg).setOnClickListener(v->{
            if (!inti.getText().toString().equals("")){
                databaseReference.child(inti.getText().toString()).removeValue();
                Log.d(TAG, "onViewCreated: supr");
            }
            findNavController(this).navigate(R.id.action_editeurMessage_to_listeMessages);
        });
        TextToSpeech textToSpeech = new TextToSpeech(this.getContext(), status -> {

        });
        textToSpeech.setLanguage(Locale.FRANCE);
        textToSpeech.setSpeechRate(1.3F);
        view.findViewById(R.id.lecteur_messages_editeur).setOnClickListener(w-> {
            textToSpeech.speak(msg.getText().toString(),TextToSpeech.QUEUE_FLUSH,null,null);
            Toast.makeText(this.getContext(),"Lecture en cours",Toast.LENGTH_SHORT).show();
        });

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_editeur_message, container, false);
    }
}