package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import java.util.HashMap;

public class MainActivity extends AppCompatActivity {
    private DatabaseReference databaseReference;
    private FirebaseUser firebaseUser;
    private String destinataire;

    public boolean isNetworkAvailable() {
        ConnectivityManager connectivityManager
                = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager != null ? connectivityManager.getActiveNetworkInfo() : null;
        return activeNetworkInfo != null && activeNetworkInfo.isConnected();
    }
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        WindowInsetsControllerCompat windowInsetsController =
                WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        windowInsetsController.hide(WindowInsetsCompat.Type.systemBars());
        windowInsetsController.setSystemBarsBehavior(
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        );
        Intent intent = getIntent();
        Uri data = intent.getData();
        if (data!=null) lien(String.valueOf(data));

    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Uri data = intent.getData();
        if (data!=null) lien(String.valueOf(data));
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        }
        return false;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 210012) {
            Log.d(TAG, "onActivityResult: "+resultCode);
            if (resultCode != RESULT_OK) {
                Log.d(TAG, "Echec de la MàJ :0 " + resultCode);
            }
        }else{
            IntentResult result = IntentIntegrator.parseActivityResult(resultCode, data);
            Log.d(TAG, "onActivityResult: "+resultCode);
            if (resultCode!= 0){
                lien (result.getContents());
            }
        }
    }

    private final ValueEventListener initConv = new ValueEventListener(){
        @Override
        public void onDataChange(DataSnapshot dataSnapshot) {
            if (!dataSnapshot.hasChildren()){   //nouvelle discussion
                HashMap<String, String> carteDeH = new HashMap<>();
                carteDeH.put("utilisateur1", destinataire);
                carteDeH.put("utilisateur2", firebaseUser.getUid());
                databaseReference.setValue(carteDeH);
            }
            Log.d(TAG, "onDataChange: "+firebaseUser.getUid());
             FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(destinataire).child("contact").setValue(firebaseUser.getUid()).addOnSuccessListener(unused -> {
                 Intent intention = new Intent(MainActivity.this,ActiviteDiscussion.class);
                 intention.putExtra("id",destinataire);
                 intention.putExtra("dis",firebaseUser.getUid()+destinataire);
                 databaseReference.removeEventListener(initConv);
                 startActivity(intention);
                 finish();
             });

        }

        @Override
        public void onCancelled(DatabaseError databaseError) {
            // Getting Post failed, log a message
            Log.w(TAG, "loadPost:onCancelled", databaseError.toException());
        }
    };

    public void lien(String code){
        destinataire = code;
        destinataire = destinataire.replace("https://","");
        destinataire = destinataire.replace("vidar-9e8ac.web.app/?dest=","");
        firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        Toast.makeText(this,"Mise à jour des données", Toast.LENGTH_LONG).show();
        assert firebaseUser != null;
        databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("ListeChats").child(firebaseUser.getUid()+destinataire);
        databaseReference.addValueEventListener(initConv);
    }


    /*@Override
    public void onBackPressed() {
        startActivity(new Intent(this, MainActivity.class));
        overridePendingTransition(
                R.anim.fade_in,
                R.anim.fade_out
        );
    }*/
}