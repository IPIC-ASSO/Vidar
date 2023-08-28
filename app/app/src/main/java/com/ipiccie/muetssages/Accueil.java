package com.ipiccie.muetssages;

import static androidx.constraintlayout.helper.widget.MotionEffect.TAG;
import static androidx.navigation.fragment.FragmentKt.findNavController;
import static com.google.android.play.core.install.model.AppUpdateType.IMMEDIATE;

import android.Manifest;
import android.content.Context;
import android.content.IntentSender;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.snackbar.Snackbar;
import com.google.android.play.core.appupdate.AppUpdateInfo;
import com.google.android.play.core.appupdate.AppUpdateManager;
import com.google.android.play.core.appupdate.AppUpdateManagerFactory;
import com.google.android.play.core.install.InstallStateUpdatedListener;
import com.google.android.play.core.install.model.AppUpdateType;
import com.google.android.play.core.install.model.InstallStatus;
import com.google.android.play.core.install.model.UpdateAvailability;
import com.google.android.play.core.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.messaging.FirebaseMessaging;

import java.util.Objects;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link Accueil#newInstance} factory method to
 * create an instance of this fragment.
 */
public class Accueil extends Fragment {

    private AppUpdateManager appUpdateManager;
    private boolean drapeau;

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
            if (ContextCompat.checkSelfPermission(this.requireContext(), Manifest.permission.POST_NOTIFICATIONS) ==
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
        //FirebaseDatabase.getInstance().setPersistenceEnabled(true);
        ActionBar ab = ((AppCompatActivity) requireActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(false);
        }
        if (Objects.equals(requireActivity().getIntent().getStringExtra("disc"), "go")){
            requireActivity().getIntent().putExtra("disc","pasgo");
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
            SharedPreferences pref = this.requireActivity().getSharedPreferences("prefs",Context.MODE_PRIVATE);
            if (pref.getBoolean("plusv",true)){
                CheckBox pluv= new CheckBox(this.requireContext());
                pluv.setText("Ne plus afficher ce message");
                pluv.setTypeface(null, Typeface.ITALIC);
                pluv.setPadding(5,5,5,5);
                pluv.setOnClickListener(v->pref.edit().putBoolean("pluv",false).apply());
                new MaterialAlertDialogBuilder(requireContext())
                        .setTitle("Connexion limitée")
                        .setMessage("Il est actuellement impossible de joindre la base de donnée. L'application passe donc en mode hors-ligne, seul la consultation des messages est disponible")
                        .setView(pluv)
                        .setNeutralButton("OK",((dialogInterface, i) -> dialogInterface.dismiss()))
                        .show();
            }
        }
        verifMaJ();
    }

    private void verifMaJ() {
        appUpdateManager = AppUpdateManagerFactory.create(this.requireContext());

        // Returns an intent object that you use to check for an update.
        Task<AppUpdateInfo> appUpdateInfoTask = appUpdateManager.getAppUpdateInfo();

        // Checks that the platform will allow the specified type of update.
        appUpdateInfoTask.addOnSuccessListener(appUpdateInfo -> {
            if (drapeau && appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {
                drapeau = false;
                Log.d(TAG, "verifMaJ: "+appUpdateInfo.clientVersionStalenessDays());
                if (appUpdateInfo.clientVersionStalenessDays() != null && (appUpdateInfo.clientVersionStalenessDays() >= 30 || appUpdateInfo.updatePriority() >= 3) && appUpdateInfo.isUpdateTypeAllowed(IMMEDIATE)) {
                    //MàJ immédiate
                    Log.d(TAG, "verifMaJ: PPP");
                    try {
                        appUpdateManager.startUpdateFlowForResult(
                                // Pass the intent that is returned by 'getAppUpdateInfo()'.
                                appUpdateInfo,
                                // Or 'AppUpdateType.FLEXIBLE' for flexible updates.
                                IMMEDIATE,
                                // The current activity making the update request.
                                this.requireActivity(),
                                // Include a request code to later monitor this update request.
                                210012);
                    } catch (IntentSender.SendIntentException e) {
                        e.printStackTrace();
                    }
                }
                else if(appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE)){
                    InstallStateUpdatedListener listener = state -> {
                        // (Optional) Provide a download progress bar.
                        if (state.installStatus() == InstallStatus.DOWNLOADING) {
                            long bytesDownloaded = state.bytesDownloaded();
                            long totalBytesToDownload = state.totalBytesToDownload();
                            //TODO: Implement progress bar.
                        }
                        if (state.installStatus() == InstallStatus.DOWNLOADED) {
                            // After the update is downloaded, show a notification
                            // and request user confirmation to restart the app.
                            popupSnackbarForCompleteUpdate();
                        }
                    };
                    // Create a listener to track request state updates.
                    // Before starting an update, register a listener for updates.
                    appUpdateManager.registerListener(listener);
                    try {
                        appUpdateManager.startUpdateFlowForResult(
                                appUpdateInfo,
                                AppUpdateType.FLEXIBLE,
                                this.requireActivity(),
                                210012);
                    } catch (IntentSender.SendIntentException e) {
                        e.printStackTrace();
                    }
                }
            }else{
                Log.d(TAG, "verifMaJ: NNNN");
            }
        });
    }

    private void popupSnackbarForCompleteUpdate() {
        Snackbar snackbar =
                Snackbar.make(this.requireView().findViewById(R.id.accueil),
                        "Mise à jour télécharg&z.",
                        Snackbar.LENGTH_INDEFINITE);
        snackbar.setAction("Redémarrer", view -> appUpdateManager.completeUpdate());
        snackbar.show();
    }

    @Override
    public void onResume() {
        super.onResume();
        appUpdateManager.getAppUpdateInfo().addOnSuccessListener(
            appUpdateInfo -> {
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                // If an in-app update is already running, resume the update.
                try {
                    appUpdateManager.startUpdateFlowForResult(appUpdateInfo, IMMEDIATE, this.requireActivity(), 210012);
                } catch (IntentSender.SendIntentException e) {
                    e.printStackTrace();
                }
            }else if (appUpdateInfo.installStatus() == InstallStatus.DOWNLOADED) {
                    popupSnackbarForCompleteUpdate();
                }
            });
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment

        return inflater.inflate(R.layout.fragment_accueil, container, false);
    }

    @Override
    public void onAttach(@NonNull Context context) {
        drapeau = true;
        super.onAttach(context);
    }
}