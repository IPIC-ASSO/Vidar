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
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import java.util.Set;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link ConfigLancerDiscussion#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ConfigLancerDiscussion extends Fragment {

    ActivityResultLauncher<String> mGetContent = registerForActivityResult(new ActivityResultContracts.GetContent(),
            new ActivityResultCallback<Uri>() {
                @Override
                public void onActivityResult(Uri uri) {
                    // Handle the returned Uri
                }
            });


    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
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
    // TODO: Rename and change types and number of parameters
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
            bundle.putString("msg_ecrit",prefs.getString(msgEcrit.getText().toString(),"Une erreur est survenue"));
            bundle.putString("msg_lu",prefs.getString(msgLu.getText().toString(),"Une erreur est survenue"));
            bundle.putString("msg_debut",prefs.getString(msgDebut.getText().toString(),"Une erreur est survenue"));
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
            msgEcrit.setText("message par defaut");
            msgLu.setText("message par defaut");
            msgDebut.setText("message par defaut");
        });
        String[] listeMsg =prefs.getAll().keySet().toArray(new String[0]);
        view.findViewById(R.id.liste_msg_ecrit).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.getContext()).setTitle("Message à afficher").setItems(listeMsg, (dialog, which) -> msgEcrit.setText(listeMsg[which])).show());
        view.findViewById(R.id.liste_msg_lu).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.getContext()).setTitle("Message à afficher").setItems(listeMsg, (dialog, which) -> msgLu.setText(listeMsg[which])).show());
        view.findViewById(R.id.liste_msg_debut).setOnClickListener(v -> new MaterialAlertDialogBuilder(this.getContext()).setTitle("Premier message de la conversation").setItems(listeMsg, (dialog, which) -> msgDebut.setText(listeMsg[which])).show());

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
}