package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnSuccessListener;
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

    }
    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
                return true;
            default:
                return false;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        IntentResult result = IntentIntegrator.parseActivityResult(resultCode, data);
        Log.d(TAG, "onActivityResult: "+resultCode);
        if (resultCode!= 0){
            destinataire = result.getContents();
            firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
            Toast.makeText(this,"Mise à jour des données", Toast.LENGTH_LONG).show();
            assert firebaseUser != null;
            databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("ListeChats").child(firebaseUser.getUid()+result.getContents());
            databaseReference.addValueEventListener(initConv);

        }
    }

    private ValueEventListener initConv = new ValueEventListener(){
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

    /*@Override
    public void onBackPressed() {
        startActivity(new Intent(this, MainActivity.class));
        overridePendingTransition(
                R.anim.fade_in,
                R.anim.fade_out
        );
    }*/
}