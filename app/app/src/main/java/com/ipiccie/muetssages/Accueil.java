package com.ipiccie.muetssages;

import static androidx.constraintlayout.helper.widget.MotionEffect.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowInsets;
import android.widget.Button;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.Objects;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link Accueil#newInstance} factory method to
 * create an instance of this fragment.
 */
public class Accueil extends Fragment {

    private final ActivityResultLauncher<String> requestPermissionLauncher =
            registerForActivityResult(new ActivityResultContracts.RequestPermission(), isGranted -> {
                if (isGranted) {
                    // FCM SDK (and your app) can post notifications.
                } else {
                    // TODO: Inform user that that your app will not show notifications.
                }
            });

    private void askNotificationPermission() {
        // This is only necessary for API level >= 33 (TIRAMISU)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this.getContext(), Manifest.permission.POST_NOTIFICATIONS) ==
                    PackageManager.PERMISSION_GRANTED) {
                // FCM SDK (and your app) can post notifications.
            } else if (shouldShowRequestPermissionRationale(Manifest.permission.POST_NOTIFICATIONS)) {
                // TODO: display an educational UI explaining to the user the features that will be enabled
                //       by them granting the POST_NOTIFICATION permission. This UI should provide the user
                //       "OK" and "No thanks" buttons. If the user selects "OK," directly request the permission.
                //       If the user selects "No thanks," allow the user to continue without notifications.
            } else {
                // Directly ask for the permission
                requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS);
            }
        }
    }


    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";


    public Accueil() {
        // Required empty public constructor
    }


    public static Accueil newInstance(String param1, String param2) {
        Accueil fragment = new Accueil();
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
            ab.setDisplayHomeAsUpEnabled(false);
        }
        Log.d(TAG, "onViewCreated: OKOK"+getActivity().getIntent().getStringExtra("disc"));
        if (Objects.equals(getActivity().getIntent().getStringExtra("disc"), "go")){
            getActivity().getIntent().putExtra("disc","pasgo");
            findNavController(this).navigate(R.id.action_accueil_to_listeConversations);
        }
        view.findViewById(R.id.nouv_conv).setOnClickListener(v-> findNavController(this).navigate(R.id.action_accueil_to_configLancerDiscussion));
        view.findViewById(R.id.vers_messages).setOnClickListener(v-> findNavController(this).navigate(R.id.action_accueil_to_listeMessages));
        view.findViewById(R.id.mes_convs).setOnClickListener(v-> findNavController(this).navigate(R.id.action_accueil_to_listeConversations));
        view.findViewById(R.id.vers_aide).setOnClickListener(v-> findNavController(this).navigate(R.id.action_accueil_to_aide));
        view.findViewById(R.id.vers_options).setOnClickListener(v-> findNavController(this).navigate(R.id.action_accueil_to_parametres));
        //view.findViewById(R.id.vers_aide).setOnClickListener(v-> Toast.makeText(this.getContext(), "Pas encore implémenté", Toast.LENGTH_SHORT).show());
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        if(firebaseUser == null){
            findNavController(this).navigate(R.id.action_accueil_to_connexion);
        }
        if(!((MainActivity)getActivity()).isNetworkAvailable()){
            new MaterialAlertDialogBuilder(getContext())
                    .setTitle("Une erreur est survenue")
                    .setMessage("Impossible de joindre la base de données.\nVérifiez votre connexion internet.\nSans connexion à la base de données, les principales fonctionnalités seront indisponibles.")
                    .setNeutralButton("OK",((dialogInterface, i) -> dialogInterface.dismiss()))
                    .show();
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

        return inflater.inflate(R.layout.fragment_accueil, container, false);
    }
}