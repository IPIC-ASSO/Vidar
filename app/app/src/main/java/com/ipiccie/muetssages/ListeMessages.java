package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.EventListener;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link ListeMessages#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ListeMessages extends Fragment {

    private HashMap<String, String> listeDeMessages;
    private FirebaseUser firebaseUser;


    public ListeMessages() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment ListeMessages.
     */
    // TODO: Rename and change types and number of parameters
    public static ListeMessages newInstance(String param1, String param2) {
        ListeMessages fragment = new ListeMessages();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        // This callback will only be called when MyFragment is at least Started.
        OnBackPressedCallback callback = new OnBackPressedCallback(true /* enabled by default */) {
            @Override
            public void handleOnBackPressed() {
                findNavController(getParentFragment()).navigate(R.id.action_listeMessages_to_accueil);
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
        ActionBar ab = ((AppCompatActivity) getActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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

            }
        });

    }
    public void inflate(ValueEventListener ecoute, DatabaseReference db){
        if (listeDeMessages.isEmpty()){
            FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid()).child("messages").child("message par defaut").setValue("Bonjour, pour communiquer plus facilement, je vous propose d'utiliser une application de messagerie instantanée");
            Log.d(TAG, "inflate: vide");
            return;
        }
        else this.getView().findViewById(R.id.instruc_liste_msg).setVisibility(View.INVISIBLE);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        params.setMargins(2,5, 2,5);
        LinearLayout liste = this.getView().findViewById(R.id.liste_messages);
        int stylebouton = com.google.android.material.R.style.Widget_MaterialComponents_Button_OutlinedButton;
        Log.d(TAG, "inflation: "+listeDeMessages);
        for (String intitule:listeDeMessages.keySet()){
            Button txt = new Button(new ContextThemeWrapper(this.getContext(),stylebouton), null, stylebouton);
            txt.setText(intitule);
            txt.setBackgroundColor(Color.parseColor("#DDDDDD"));
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