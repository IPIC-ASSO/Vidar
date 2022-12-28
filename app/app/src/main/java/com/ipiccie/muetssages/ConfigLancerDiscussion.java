package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.zxing.integration.android.IntentIntegrator;

import java.util.HashMap;
import java.util.Objects;

public class ConfigLancerDiscussion extends Fragment {

    private HashMap<String, String> listeDeMessages;
    private String[] listeMsg;


    public ConfigLancerDiscussion() {
        // Required empty public constructor
    }


    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Button versLanceDis = view.findViewById(R.id.vers_lance_discussion);
        Button versScanneur = view.findViewById(R.id.vers_scanneur);
        TextView msgEcrit = view.findViewById(R.id.message_ecrit);
        TextView msgLu = view.findViewById(R.id.message_lu);
        TextView msgDebut = view.findViewById(R.id.message_debut);
        Bundle bundle = new Bundle();

        versLanceDis.setOnClickListener(v->{
            bundle.putString("msg_ecrit",listeDeMessages.getOrDefault(msgEcrit.getText().toString()," "));
            bundle.putString("msg_lu",listeDeMessages.getOrDefault(msgLu.getText().toString()," "));
            bundle.putString("msg_debut",listeDeMessages.getOrDefault(msgDebut.getText().toString()," "));
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

        listeMessages(view);

        ActionBar ab = ((AppCompatActivity) requireActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        return item.getItemId() == android.R.id.home;
    }



    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_config_lancer_discussion, container, false);
    }

    public void listeMessages(View v){
        try {
        listeDeMessages = new HashMap<>();
        DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(Objects.requireNonNull(FirebaseAuth.getInstance().getCurrentUser()).getUid()).child("messages");
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
                initEcouteur(v);
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

    private void initEcouteur(View view) {
        TextView msgEcrit = view.findViewById(R.id.message_ecrit);
        TextView msgLu = view.findViewById(R.id.message_lu);
        TextView msgDebut = view.findViewById(R.id.message_debut);
        view.findViewById(R.id.liste_msg_ecrit).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.requireContext()).setTitle(getString(R.string.txt_indic_message_dessus_QR)).setItems(listeMsg, (dialog, which) -> msgEcrit.setText(listeMsg[which])).show());
        view.findViewById(R.id.liste_msg_lu).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.requireContext()).setTitle(getString(R.string.txt_indic_msg_lu)).setItems(listeMsg, (dialog, which) -> msgLu.setText(listeMsg[which])).show());
        view.findViewById(R.id.liste_msg_debut).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.requireContext()).setTitle(getString(R.string.txt_indic_msg_debut_conv)).setItems(listeMsg, (dialog, which) -> msgDebut.setText(listeMsg[which])).show());
    }
}