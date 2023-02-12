package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.ipiccie.muetssages.adaptateur.AdaptateurAdapte;
import com.ipiccie.muetssages.client.Discussion;
import com.ipiccie.muetssages.client.Utilisateur;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class listeConversations extends Fragment {


    private ValueEventListener grosEcouteur;
    private RecyclerView recyclerView;
    private List<Utilisateur> listeU;
    private Utilisateur utilisateur;
    private DatabaseReference databaseReference;
    private DatabaseReference databaseReference2;
    private static final String db = "https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app";


    public listeConversations() {
        // Required empty public constructor
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ActionBar ab = ((AppCompatActivity) requireActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
        // This callback will only be called when MyFragment is at least Started.
        OnBackPressedCallback callback = new OnBackPressedCallback(true /* enabled by default */) {
            @Override
            public void handleOnBackPressed() {
                if (getParentFragment() != null) {
                    findNavController(getParentFragment()).navigate(R.id.action_listeConversations_to_accueil);
                }
                this.remove();
                }
        };
        requireActivity().getOnBackPressedDispatcher().addCallback(getViewLifecycleOwner(), callback);
    }

    @Override
    public void onPause() {
        super.onPause();
        if (grosEcouteur!= null){
            databaseReference.removeEventListener(grosEcouteur);
        }

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_liste_conversations, container, false);
        recyclerView = view.findViewById(R.id.recyclage);
        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(new LinearLayoutManager(this.getContext()));
        listeU = new ArrayList<>();
        litU(view);
        return view;
    }

    private void litU(View vue) {
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        assert firebaseUser != null;

        databaseReference = FirebaseDatabase.getInstance(db).getReference().child("Users").child(firebaseUser.getUid());
        databaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                utilisateur = snapshot.getValue(Utilisateur.class);
                List<String> contacts = new ArrayList<>();
                List<String> idConv = new ArrayList<>();
                List<Boolean> listsup = new ArrayList<>();
                databaseReference = FirebaseDatabase.getInstance(db).getReference().child("ListeChats");
                grosEcouteur = new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        contacts.clear();
                        idConv.clear();
                        listsup.clear();
                        for (DataSnapshot snapshot1: snapshot.getChildren()){
                            Discussion dis = snapshot1.getValue(Discussion.class);
                            if (dis != null && dis.getUtilisateur1()!= null && dis.getUtilisateur2()!=null && utilisateur != null && !Objects.equals(dis.getSupr(), utilisateur.getId())) {
                                if(Objects.equals(dis.getUtilisateur1(), utilisateur.getId())){
                                    contacts.add(dis.getUtilisateur2());
                                    idConv.add(dis.getUtilisateur2()+dis.getUtilisateur1());
                                    listsup.add(dis.getSupr()!=null);
                                }else if (Objects.equals(dis.getUtilisateur2(), utilisateur.getId())){
                                    contacts.add(dis.getUtilisateur1());
                                    idConv.add(dis.getUtilisateur2()+dis.getUtilisateur1());
                                    listsup.add(dis.getSupr()!=null);
                                }
                                Log.d(TAG, "onDataChange3: "+dis.getUtilisateur1()+dis.getUtilisateur2());
                            }
                        }
                        Log.d(TAG, "onDataChangelistesup: "+listsup);
                        databaseReference2 = FirebaseDatabase.getInstance(db).getReference().child("Users");
                        listeU.clear();
                        ValueEventListener ecoute = this;
                        for (String contact: contacts){
                            databaseReference2.child(contact).addValueEventListener(new ValueEventListener() {
                                @Override
                                public void onDataChange(@NonNull DataSnapshot snapshot) {
                                    Log.d(TAG, "onDataChange: "+snapshot.getValue());
                                    if (snapshot.getValue()!= null) listeU.add(snapshot.getValue(Utilisateur.class));
                                    databaseReference2.removeEventListener(this);
                                    if(Objects.equals(contact, contacts.get(contacts.size()-1)))affiche(vue, idConv, ecoute, listsup.toArray(new Boolean[0]));
                                }
                                @Override
                                public void onCancelled(@NonNull DatabaseError error) {
                                    Log.d(TAG, "onCancelled3: "+error);
                                }
                            });
                        }
                    }
                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        Log.d(TAG, "onCancelled2: "+error);
                    }
                };

                databaseReference.addValueEventListener(grosEcouteur);
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.d(TAG, "onCancelled1: "+error);
            }
        });
    }

    public void affiche(View vue, List<String> idConv, ValueEventListener v, Boolean[] listeSup){
        if(getContext()!= null){
            if(!listeU.isEmpty())vue.findViewById(R.id.pas_de_conv).setVisibility(View.GONE);
            AdaptateurAdapte adaptateurAdapte = new AdaptateurAdapte(requireContext(), listeU, idConv, listeSup);
            recyclerView.setAdapter(adaptateurAdapte);
            databaseReference.removeEventListener(v);
        }
    }
}