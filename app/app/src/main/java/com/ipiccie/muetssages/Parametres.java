package com.ipiccie.muetssages;

import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.DialogInterface;
import android.content.res.Configuration;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.fragment.app.Fragment;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.EditText;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.ipiccie.muetssages.client.Utilisateur;
import com.journeyapps.barcodescanner.Util;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link Parametres#newInstance} factory method to
 * create an instance of this fragment.
 */
public class Parametres extends Fragment {

    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;
    private DatabaseReference databaseReference;
    private Utilisateur utilisateur;

    public Parametres() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment Parametres.
     */
    // TODO: Rename and change types and number of parameters
    public static Parametres newInstance(String param1, String param2) {
        Parametres fragment = new Parametres();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ActionBar ab = ((AppCompatActivity) getActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid());
        databaseReference.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                utilisateur = snapshot.getValue(Utilisateur.class);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });

        view.findViewById(R.id.deco).setOnClickListener(v-> new MaterialAlertDialogBuilder(this.getContext())
                .setTitle("Déconnexion")
                .setMessage("Voulez-vous vraiment vous déconnecter?")
                .setPositiveButton(getString(R.string.btn_deco), (dialogInterface, i) -> {
                    FirebaseAuth.getInstance().signOut();
                    findNavController(this).navigate(R.id.action_parametres_to_connexion);
                })
                .setNegativeButton("Annuler",(dialogInterface, i) ->dialogInterface.dismiss())
                .show());
        com.google.android.material.switchmaterial.SwitchMaterial modeSombre = view.findViewById(R.id.switch_mode_sombre);
        int currentNightMode = getContext().getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;
        // Night mode is active, we're using dark theme
        modeSombre.setChecked(currentNightMode != Configuration.UI_MODE_NIGHT_NO);
        modeSombre.setOnCheckedChangeListener((compoundButton, b) -> {
            if (b) AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
            else AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
        });
        view.findViewById(R.id.change_pseudo).setOnClickListener(v->{
            EditText pseudo = new EditText(this.getContext());
            pseudo.setPadding(10,10,10,10);
            pseudo.setHint(getString(R.string.hint_pseudo));
            pseudo.setText(utilisateur.getUsername());
            new MaterialAlertDialogBuilder(this.getContext())
                    .setView(pseudo)
                    .setTitle(getString(R.string.btn_changer_btn))
                    .setPositiveButton("Valider", (dialogInterface, i) -> {
                        utilisateur.setUsername(pseudo.getText().toString());
                        databaseReference.setValue(utilisateur);
                        dialogInterface.dismiss();
                    })
                    .setNegativeButton("Annuler", (dialogInterface, i) -> dialogInterface.dismiss())
                    .show();
        });
        view.findViewById(R.id.change_mdp).setOnClickListener(v ->{
                EditText mdp = new EditText(this.getContext());
                mdp.setPadding(10,10,10,10);
                mdp.setHint("Nouveau mot de passe");
                new MaterialAlertDialogBuilder(this.getContext())
                        .setView(mdp)
                        .setTitle(getString(R.string.btn_changer_mdp))
                        .setPositiveButton("Valider", (dialogInterface, i) -> {
                            firebaseUser.updatePassword(mdp.getText().toString());
                            dialogInterface.dismiss();
                        })
                        .setNegativeButton("Annuler", (dialogInterface, i) -> dialogInterface.dismiss())
                        .show();
                });
            }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_parametres, container, false);
    }
}