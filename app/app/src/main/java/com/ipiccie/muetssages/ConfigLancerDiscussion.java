package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.transition.TransitionInflater;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link ConfigLancerDiscussion#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ConfigLancerDiscussion extends Fragment {


    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";
    private HashMap<String, String> listeDeMessages;
    private String[] listeMsg;


    private String mParam1;
    private String mParam2;

    public ConfigLancerDiscussion() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment ConfigLancerDiscussion.
     */

    public static ConfigLancerDiscussion newInstance(String param1, String param2) {
        ConfigLancerDiscussion fragment = new ConfigLancerDiscussion();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        SharedPreferences prefs =this.getActivity().getBaseContext().getSharedPreferences("classes", Context.MODE_PRIVATE);//liste des intitulés et message associé
        Button versLanceDis = view.findViewById(R.id.vers_lance_discussion);
        Button versScanneur = view.findViewById(R.id.vers_scanneur);
        TextView msgEcrit = view.findViewById(R.id.message_ecrit);
        TextView msgLu = view.findViewById(R.id.message_lu);
        TextView msgDebut = view.findViewById(R.id.message_debut);
        Bundle bundle = new Bundle();

        versLanceDis.setOnClickListener(v->{
            bundle.putString("msg_ecrit",listeDeMessages.getOrDefault(msgEcrit.getText().toString(),getString(R.string.erreur)));
            bundle.putString("msg_lu",listeDeMessages.getOrDefault(msgLu.getText().toString(),getString(R.string.erreur)));
            bundle.putString("msg_debut",listeDeMessages.getOrDefault(msgDebut.getText().toString(),getString(R.string.erreur)));
            findNavController(this).navigate(R.id.action_configLancerDiscussion_to_lanceDiscussion,bundle);
        });
        versScanneur.setOnClickListener(v-> {
            try {
                IntentIntegrator intentIntegrator = new IntentIntegrator(this.getActivity());
                intentIntegrator.setDesiredBarcodeFormats(IntentIntegrator.QR_CODE);
                intentIntegrator.initiateScan();
            } catch (Exception e) {
                Log.e(TAG, "onViewCreated: ",e);
                Toast.makeText(this.getContext(),"Erreur. Vérifiez que l'application est autorisée à utiliser la caméra",Toast.LENGTH_LONG).show();
            }
        });
        view.findViewById(R.id.creer_qr).setOnClickListener(v->{
            v.setVisibility(View.GONE);
            view.findViewById(R.id.groupe1).animate().alpha(0.0F);
            view.findViewById(R.id.groupe2).setVisibility(View.VISIBLE);
            msgEcrit.setText(getString(R.string.msg_defaut));
            msgLu.setText(getString(R.string.msg_defaut));
            msgDebut.setText(getString(R.string.msg_defaut));
        });

        liste_messages(view);

        ActionBar ab = ((AppCompatActivity) getActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                return true;
            default:
                return false;
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
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_config_lancer_discussion, container, false);
    }

    public void liste_messages(View v){
        try {

        listeDeMessages = new HashMap<>();
        DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(FirebaseAuth.getInstance().getCurrentUser().getUid()).child("messages");
        databaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                listeDeMessages.clear();
                Log.d(TAG, "onDataChange: "+snapshot.getValue());
                if (snapshot.getValue()!= null){
                    listeDeMessages = (HashMap<String, String>) snapshot.getValue();
                }else listeDeMessages.put("message par defaut","Bonjour, pour communiquer plus facilement, je vous propose d'utiliser une application de messagerie instantanée");
                listeMsg = listeDeMessages.keySet().toArray(new String[0]);
                databaseReference.removeEventListener(this);
                init_ecouteur(v);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(getContext(),"Serveur injoignable",Toast.LENGTH_SHORT).show();
            }
        });
        }catch (Exception e){
            Log.e(TAG, "liste_messages: ",e);
            Toast.makeText(this.getContext(),"Une erreur est survenue",Toast.LENGTH_SHORT).show();
        }
    }

    private void init_ecouteur(View view) {
        TextView msgEcrit = view.findViewById(R.id.message_ecrit);
        TextView msgLu = view.findViewById(R.id.message_lu);
        TextView msgDebut = view.findViewById(R.id.message_debut);
        view.findViewById(R.id.liste_msg_ecrit).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.getContext()).setTitle(getString(R.string.txt_indic_message_dessus_QR)).setItems(listeMsg, (dialog, which) -> msgEcrit.setText(listeMsg[which])).show());
        view.findViewById(R.id.liste_msg_lu).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.getContext()).setTitle(getString(R.string.txt_indic_msg_lu)).setItems(listeMsg, (dialog, which) -> msgLu.setText(listeMsg[which])).show());
        view.findViewById(R.id.liste_msg_debut).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.getContext()).setTitle(getString(R.string.txt_indic_msg_debut_conv)).setItems(listeMsg, (dialog, which) -> msgDebut.setText(listeMsg[which])).show());
    }
}