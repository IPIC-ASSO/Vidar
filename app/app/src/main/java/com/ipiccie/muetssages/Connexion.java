package com.ipiccie.muetssages;

import static androidx.fragment.app.FragmentManager.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.ipiccie.muetssages.client.Utilisateur;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link Connexion#newInstance} factory method to
 * create an instance of this fragment.
 */
public class Connexion extends Fragment {

    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";


    private FirebaseAuth auth;
    private DatabaseReference reference;

    public Connexion() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment Connexion.
     */
    // TODO: Rename and change types and number of parameters
    public static Connexion newInstance(String param1, String param2) {
        Connexion fragment = new Connexion();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        SharedPreferences prefs = requireContext().getSharedPreferences("classes", Context.MODE_PRIVATE);
        CheckBox souviens = view.findViewById(R.id.souvenir_moi);

        if (prefs.getBoolean("souvenir",false)){
            souviens.setChecked(true);
            EditText mailCo= view.findViewById(R.id.mail_connexion);
            mailCo.setText(prefs.getString("mail",""));
            EditText mdpCo= view.findViewById(R.id.motdepasse_connexion);
            mdpCo.setText(prefs.getString("mdp",""));
        }
        souviens.setOnCheckedChangeListener((compoundButton, b) -> prefs.edit().putBoolean("souvenir",b).apply());
        auth = FirebaseAuth.getInstance();
        view.findViewById(R.id.connexion).setOnClickListener(v->{
            view.findViewById(R.id.bloc_1).setVisibility(View.GONE);
            view.findViewById(R.id.bloc_2).setVisibility(View.VISIBLE);
        });
        view.findViewById(R.id.inscription).setOnClickListener(v->{
            view.findViewById(R.id.bloc_1).setVisibility(View.GONE);
            view.findViewById(R.id.bloc_3).setVisibility(View.VISIBLE);
        });
        view.findViewById(R.id.btn_valider_connection).setOnClickListener(v->{
            EditText mail = view.findViewById(R.id.mail_connexion);
            EditText motDePasse = view.findViewById(R.id.motdepasse_connexion);
            if(!mail.getText().toString().equals("")&&!motDePasse.getText().toString().equals("")) {
                if (souviens.isChecked()){
                    prefs.edit().putString("mail",mail.getText().toString()).apply();
                    prefs.edit().putString("mdp",motDePasse.getText().toString()).apply();
                }
                connexion(mail.getText().toString(),motDePasse.getText().toString());
            }
            else{
                Toast.makeText(getContext(),"Veuillez remplir tous les champs",Toast.LENGTH_SHORT).show();
            }
        });
        view.findViewById(R.id.btn_valider_inscription).setOnClickListener(v->{
            EditText mail = view.findViewById(R.id.mail_inscription);
            EditText uti = view.findViewById(R.id.nom_utilisateur);
            EditText motDePasse = view.findViewById(R.id.motdepasse_inscription);
            if(!mail.getText().toString().equals("")&&!uti.getText().toString().equals("")&&!motDePasse.getText().toString().equals("")) inscription(uti.getText().toString(), mail.getText().toString(),motDePasse.getText().toString());
            else{
                Toast.makeText(getContext(),"Veuillez remplir tous les champs",Toast.LENGTH_SHORT).show();
            }
        });

        view.findViewById(R.id.mdp_oublie).setOnClickListener(v->{
            EditText mail = new EditText(this.getContext());
            mail.setHint("adresse e-mail");
            new MaterialAlertDialogBuilder(this.requireContext())
                    .setTitle("Mot de passe oublié")
                    .setView(mail)
                    .setMessage("Saisissez votre adresse e-mail pour recevoir un lien de réinitialisation.\nPensez à vérifier vos spam.")
                    .setNegativeButton("annuler",((dialogInterface, i) -> dialogInterface.dismiss()))
                    .setPositiveButton("Valider",((dialogInterface, i) -> {
                        FirebaseAuth.getInstance().sendPasswordResetEmail(mail.getText().toString());
                        dialogInterface.dismiss();
                        Toast.makeText(this.getContext(), "Un lien de récupération vous a été envoyé", Toast.LENGTH_LONG).show();}))
                    .show();
        });

    }

    private void connexion( String email, String motDePasse){
        auth.signInWithEmailAndPassword(email,motDePasse).addOnCompleteListener(task -> {
             if (task.isSuccessful()){
                 Toast.makeText(getContext(), "Bienvenue ", Toast.LENGTH_SHORT).show();
                 findNavController(this).navigate(R.id.action_connexion_to_accueil);
             }else{
                 Toast.makeText(getContext(),"Impossible de vous identifier. Veuillez réessayer ", Toast.LENGTH_SHORT).show();
             }
        });
    }

    private void inscription (final String nomUtilisateur, String email, String motDePasse){
        Fragment ca = this;
        auth.createUserWithEmailAndPassword(email,motDePasse).addOnCompleteListener(task -> {
            if (task.isSuccessful()){
                FirebaseUser firebaseUser = auth.getCurrentUser();
                assert firebaseUser!=null;
                String idUtilisateur = firebaseUser.getUid();
                reference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(idUtilisateur);
                Utilisateur uti = new Utilisateur(idUtilisateur,"defaut",nomUtilisateur,"");
                reference.setValue(uti).addOnCompleteListener(task1 -> {
                    if (task1.isSuccessful()|| task1.isComplete()) {
                        ca.onStop();
                        findNavController(ca).navigate(R.id.action_connexion_to_accueil);
                    }
                }).addOnFailureListener(new OnFailureListener() {
                    @SuppressLint("RestrictedApi")
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.d(TAG, "onFailure: "+e);
                    }
                });
                Toast.makeText(getContext(), "Bienvenue "+nomUtilisateur, Toast.LENGTH_SHORT).show();
            }else{
                Toast.makeText(getContext(), "Enregistrement impossible avec cet email ou ce mot de passe"+" "+task.getException(), Toast.LENGTH_SHORT).show();
            }
        });

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_connexion, container, false);
    }
}