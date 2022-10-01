package com.ipiccie.muetssages;

import static android.content.ContentValues.TAG;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.widget.Toast;

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
import com.ipiccie.muetssages.client.Utilisateur;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

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

            FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
            Toast.makeText(this,"Mise à jour des données", Toast.LENGTH_LONG).show();
            assert firebaseUser != null;
            DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(result.getContents());
            databaseReference.addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    Utilisateur uti = snapshot.getValue(Utilisateur.class);
                    List<String> listC = new ArrayList<>();
                    if (uti != null && uti.getContacts()!= null) {
                        listC = uti.getContacts();
                    }
                    if (!listC.contains(firebaseUser.getUid())) listC.add(firebaseUser.getUid());
                    databaseReference.child("contacts").setValue(listC).addOnSuccessListener(unused -> {
                        DatabaseReference databaseReference2 = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(firebaseUser.getUid());
                        databaseReference2.addValueEventListener(new ValueEventListener() {
                            @Override
                            public void onDataChange(@NonNull DataSnapshot snapshot) {
                                Utilisateur uti2 = snapshot.getValue(Utilisateur.class);
                                List<String> listD = new ArrayList<>();
                                if (uti2 != null && uti2.getContacts()!=null) {
                                    listD = uti2.getContacts();
                                }
                                if (!listD.contains(result.getContents())) listD.add(result.getContents());
                                databaseReference2.child("contacts").setValue(listD).addOnSuccessListener(unused1 -> {
                                    Intent intention = new Intent(MainActivity.this,ActiviteDiscussion.class);
                                    intention.putExtra("id",result.getContents());
                                    startActivity(intention);
                                    finish();
                                });
                            }

                            @Override
                            public void onCancelled(@NonNull DatabaseError error) {

                            }
                        });
                    });
                }

                @Override
                public void onCancelled(@NonNull DatabaseError error) {

                }
            });
        }
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