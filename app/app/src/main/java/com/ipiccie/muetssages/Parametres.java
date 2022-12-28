package com.ipiccie.muetssages;

import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.res.Configuration;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.fragment.app.Fragment;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.ipiccie.muetssages.client.Utilisateur;


public class Parametres extends Fragment {

    private DatabaseReference databaseReference;
    private Utilisateur utilisateur;

    public Parametres() {
        // Required empty public constructor
    }



    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
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
                        .setPositiveButton("Valider", (dialogInterface, i) -> {
                            if(pseudo.getText().toString().length()>0){
                                utilisateur.setUsername(pseudo.getText().toString());
                                databaseReference.setValue(utilisateur);
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
                                    firebaseUser.updatePassword(mdp.getText().toString());
                                }
                                dialogInterface.dismiss();
                            }
                        })
                        .setNegativeButton("Annuler", (dialogInterface, i) -> dialogInterface.dismiss())
                        .show();
                });
            }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_parametres, container, false);
    }
}