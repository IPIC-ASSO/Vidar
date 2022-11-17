package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

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
import java.util.Arrays;
import java.util.EventListener;
import java.util.List;
import java.util.Objects;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link listeConversations#newInstance} factory method to
 * create an instance of this fragment.
 */
public class listeConversations extends Fragment {

    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";


    private RecyclerView recyclerView;
    private AdaptateurAdapte adaptateurAdapte;
    private List<Utilisateur> listeU;
    private Utilisateur utilisateur;
    private String mParam1;
    private String mParam2;
    private DatabaseReference databaseReference;
    private DatabaseReference databaseReference2;

    public listeConversations() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment listeConversations.
     */
    // TODO: Rename and change types and number of parameters
    public static listeConversations newInstance(String param1, String param2) {
        listeConversations fragment = new listeConversations();
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

        databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid());
        databaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                utilisateur = snapshot.getValue(Utilisateur.class);
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });
        List<String> contacts = new ArrayList<>();
        List<String> idConv = new ArrayList<>();
        databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("ListeChats");
        databaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                contacts.clear();
                idConv.clear();
                for (DataSnapshot snapshot1: snapshot.getChildren()){
                    Discussion dis = snapshot1.getValue(Discussion.class);
                    if (dis != null && dis.getUtilisateur1()!= null &&dis.getUtilisateur2()!=null) {
                        if(Objects.equals(dis.getUtilisateur1(), utilisateur.getId())){
                            contacts.add(dis.getUtilisateur1());
                            idConv.add(dis.getUtilisateur2()+dis.getUtilisateur1());
                        } else if (Objects.equals(dis.getUtilisateur2(), utilisateur.getId())){
                            contacts.add(dis.getUtilisateur2());
                            idConv.add(dis.getUtilisateur2()+dis.getUtilisateur1());
                        }
                        Log.d(TAG, "onDataChange: "+dis.getUtilisateur1()+dis.getUtilisateur2());
                    }
                }
                databaseReference2 = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users");
                listeU.clear();
                ValueEventListener ecoute = this;
                for (String contact: contacts){
                    databaseReference2.child(contact).addValueEventListener(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot snapshot) {
                            Log.d(TAG, "onDataChange: "+snapshot.getValue());
                            if (snapshot.getValue()!= null) listeU.add(snapshot.getValue(Utilisateur.class));
                            Log.d(TAG, "onDataChange: "+listeU.size());
                            databaseReference2.removeEventListener(this);
                            if(Objects.equals(contact, contacts.get(contacts.size()-1)))affiche(vue, idConv, ecoute);
                        }
                        @Override
                        public void onCancelled(@NonNull DatabaseError error) {
                        }
                    });
                }
            }
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
            }
        });
    }

    public void affiche(View vue, List<String> idConv, ValueEventListener v){
        if(listeU.size()>0)vue.findViewById(R.id.pas_de_conv).setVisibility(View.GONE);
        adaptateurAdapte = new AdaptateurAdapte(requireContext(),listeU,idConv);
        recyclerView.setAdapter(adaptateurAdapte);
        databaseReference.removeEventListener(v);
    }
}