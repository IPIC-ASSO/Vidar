package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.speech.tts.Voice;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.fragment.app.Fragment;

import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.ipiccie.muetssages.client.Utilisateur;

import java.util.Locale;


public class Parametres extends Fragment {

    private DatabaseReference databaseReference;
    private Utilisateur utilisateur;

    public Parametres() {
        // Required empty public constructor
    }



    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        SharedPreferences pref = this.requireActivity().getSharedPreferences("prefs", Context.MODE_PRIVATE);
        ActionBar ab = ((AppCompatActivity) requireActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        if (firebaseUser != null) {
            databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid());
        }
        databaseReference.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                utilisateur = snapshot.getValue(Utilisateur.class);
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                //RàS
            }
        });

        view.findViewById(R.id.deco).setOnClickListener(v-> new MaterialAlertDialogBuilder(this.requireContext())
                .setTitle(getString(R.string.pop_titre_deco))
                .setMessage(getString(R.string.pop_msg_deco))
                .setPositiveButton(getString(R.string.btn_deco), (dialogInterface, i) -> {
                    FirebaseAuth.getInstance().signOut();
                    findNavController(this).navigate(R.id.action_parametres_to_connexion);
                })
                .setNegativeButton(R.string.annuler,(dialogInterface, i) ->dialogInterface.dismiss())
                .show());
        com.google.android.material.switchmaterial.SwitchMaterial modeSombre = view.findViewById(R.id.switch_mode_sombre);
        int currentNightMode = requireContext().getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;
        // Night mode is active, we're using dark theme
        modeSombre.setChecked(currentNightMode != Configuration.UI_MODE_NIGHT_NO);
        modeSombre.setOnCheckedChangeListener((compoundButton, b) -> {
            if (b) AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
            else AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
        });
        view.findViewById(R.id.change_pseudo).setOnClickListener(v->{
            if (utilisateur==null){
                Toast.makeText(getContext(), "Une erreur est survenue, vérifiez votre connexion internet.", Toast.LENGTH_LONG).show();
            }else{
                EditText pseudo = new EditText(this.getContext());
                pseudo.setPadding(10,10,10,10);
                pseudo.setHint(getString(R.string.hint_pseudo));
                pseudo.setText(utilisateur.getUsername());
                new MaterialAlertDialogBuilder(this.requireContext())
                        .setView(pseudo)
                        .setTitle(getString(R.string.btn_changer_btn))
                        .setPositiveButton(getString(R.string.valider), (dialogInterface, i) -> {
                            if(pseudo.getText().toString().length()>0){
                                utilisateur.setUsername(pseudo.getText().toString());
                                databaseReference.child("username").setValue(pseudo.getText().toString()).addOnSuccessListener(unused -> Toast.makeText(requireContext(), String.format("Bonjour %s!",pseudo.getText().toString()), Toast.LENGTH_SHORT).show());

                                dialogInterface.dismiss();
                            }
                        })
                        .setNegativeButton("Annuler", (dialogInterface, i) -> dialogInterface.dismiss())
                        .show();
            }
        });
        view.findViewById(R.id.change_mdp).setOnClickListener(v ->{
                EditText mdp = new EditText(this.getContext());
                mdp.setPadding(10,10,10,10);
                mdp.setHint(R.string.hint_nouv_mdp);
                new MaterialAlertDialogBuilder(this.requireContext())
                        .setView(mdp)
                        .setTitle(getString(R.string.btn_changer_mdp))
                        .setPositiveButton("Valider", (dialogInterface, i) -> {
                            if(mdp.getText().toString().length()>0){
                                if (firebaseUser != null) {
                                    firebaseUser.updatePassword(mdp.getText().toString()).addOnSuccessListener(new OnSuccessListener<Void>() {
                                        @Override
                                        public void onSuccess(Void unused) {
                                            Toast.makeText(requireContext(), getString(R.string.toast_maj_mdp), Toast.LENGTH_SHORT).show();
                                        }
                                    });

                                }
                                dialogInterface.dismiss();
                            }
                        })
                        .setNegativeButton("Annuler", (dialogInterface, i) -> dialogInterface.dismiss())
                        .show();
                });
        view.findViewById(R.id.notes_version).setOnClickListener(v-> new MaterialAlertDialogBuilder(this.requireContext())
                .setTitle(getString(R.string.btn_notes_version))
                .setMessage(String.format("Vous utilisez actuellement la %s de Vidar \n%s",getString(R.string.version),getString(R.string.notes_version)))
                .setNeutralButton(getString(R.string.btn_fermer), (dialogInterface, i) -> dialogInterface.dismiss())
                .show());
        view.findViewById(R.id.politique_conf).setOnClickListener(v->{
            Uri uri = Uri.parse("https://docs.google.com/document/d/1P6C6ESkxnLY3JsDM0D38scITB3YxAliEFzSw1db3X8E/"); // missing 'http://' will cause crashed
            Intent intent = new Intent(Intent.ACTION_VIEW, uri);
            startActivity(intent);
        });
        view.findViewById(R.id.contact).setOnClickListener(v-> startActivity(new Intent(this.requireContext(),NousContacter.class)));

        initVoix(view);
    }


    public void initVoix(View v){
        SharedPreferences pref = this.requireActivity().getSharedPreferences("prefs",Context.MODE_PRIVATE);
        String voii = pref.getString("voix","fr-FR-language");
        TextToSpeech textToSpeech = new TextToSpeech(this.requireContext(), status -> Log.d(TAG, "onViewCreated: "+"tts init"),"com.google.android.tts");
        textToSpeech.setSpeechRate(1.3F);
        textToSpeech.setLanguage(Locale.FRANCE);
        Button choix = (Button) v.findViewById(R.id.choisit_voix);
        choix.setText(voii);
        choix.setOnClickListener(ve->{
            ScrollView scrollView = new ScrollView(this.requireContext());
            LinearLayout liste = new LinearLayout(this.requireContext());
            liste.setOrientation(LinearLayout.VERTICAL);
            RadioGroup groupeRadio = new RadioGroup(this.requireContext());
            for (Voice tmpVoice : textToSpeech.getVoices()) {
                RadioButton btn = new RadioButton(this.requireContext());
                btn.setText(tmpVoice.getName());
                groupeRadio.addView(btn);
                if (tmpVoice.getName().equals(voii)) {
                    btn.setChecked(true);
                }
                btn.setOnTouchListener((view, motionEvent) -> {
                    lecture(tmpVoice, textToSpeech);
                    return false;
                });
            }
            scrollView.addView(groupeRadio);
            new MaterialAlertDialogBuilder(this.requireContext())
                    .setTitle("Voix")
                    .setView(scrollView)
                    .setPositiveButton("Valider", (dialogInterface, i) -> {
                        RadioButton btn = groupeRadio.findViewById(groupeRadio.getCheckedRadioButtonId());
                        pref.edit().putString("voix",btn.getText().toString()).apply();
                        choix.setText(btn.getText().toString());
                        dialogInterface.dismiss();
                    })
                    .show();
        });


    }

    public void lecture (Voice voix, TextToSpeech tts){
        tts.setVoice(voix);
        tts.speak("Bonjour!",TextToSpeech.QUEUE_FLUSH,null,null);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_parametres, container, false);
    }
}