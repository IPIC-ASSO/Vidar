package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.res.Resources;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.fragment.app.Fragment;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.HashMap;

public class ListeMessages extends Fragment {

    private HashMap<String, String> listeDeMessages;
    private FirebaseUser firebaseUser;


    public ListeMessages() {
        // Required empty public constructor
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        // This callback will only be called when MyFragment is at least Started.
        OnBackPressedCallback callback = new OnBackPressedCallback(true /* enabled by default */) {
            @Override
            public void handleOnBackPressed() {
                findNavController(requireParentFragment()).navigate(R.id.action_listeMessages_to_accueil);
                this.remove();
            }
        };
        requireActivity().getOnBackPressedDispatcher().addCallback(getViewLifecycleOwner(), callback);


        view.findViewById(R.id.nouveau_message).setOnClickListener(w->{
            Bundle bundle = new Bundle();
            bundle.putString("intitulé", "inconnu au bataillon");
            callback.remove();
            findNavController(this).navigate(R.id.action_listeMessages_to_editeurMessage,bundle);
        });
        firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        inflation();
        ActionBar ab = ((AppCompatActivity) requireActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_liste_messages, container, false);
    }

    public void inflation(){
        listeDeMessages = new HashMap<>();
        DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid()).child("messages");
        databaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                listeDeMessages.clear();
                Log.d(TAG, "onDataChange: "+snapshot.getValue());
                if (snapshot.getValue()!= null){
                    listeDeMessages = (HashMap<String, String>) snapshot.getValue();

                }
                inflate(this, databaseReference);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.d(TAG, "onCancelled: "+error);
            }
        });

    }
    public void inflate(ValueEventListener ecoute, DatabaseReference db){
        if (listeDeMessages.isEmpty()){
            FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid()).child("messages").child("message par defaut").setValue("Bonjour, pour communiquer plus facilement, je vous propose d'utiliser une application de messagerie instantanée");
            Log.d(TAG, "inflate: vide");
            return;
        }
        else this.requireView().findViewById(R.id.instruc_liste_msg).setVisibility(View.INVISIBLE);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        params.setMargins(2,5, 2,5);
        LinearLayout liste = this.requireView().findViewById(R.id.liste_messages);
        int stylebouton = com.google.android.material.R.style.Widget_MaterialComponents_Button_OutlinedButton;
        Log.d(TAG, "inflation: "+listeDeMessages);
        for (String intitule:listeDeMessages.keySet()){
            Button txt = new Button(new ContextThemeWrapper(this.getContext(),stylebouton), null, stylebouton);
            txt.setText(intitule);
            txt.setTextColor(getResources().getColor(R.color.bleu_doux));
            txt.setBackgroundResource(R.color.fond_msg);
            txt.setLayoutParams(params);
            liste.addView(txt);
            final String msg = listeDeMessages.get(intitule);
            txt.setOnClickListener(w->{
                Bundle bundle = new Bundle();
                bundle.putString("intitulé", intitule);
                bundle.putString("message",msg);
                findNavController(this).navigate(R.id.action_listeMessages_to_editeurMessage,bundle);
            });
        }
        db.removeEventListener(ecoute);
    }

}