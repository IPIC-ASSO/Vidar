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
            DatabaseReference databaseReference = FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Chats").child(firebaseUser.getUid()+result.getContents());
            databaseReference.addValueEventListener(new ValueEventListener(){
                @Override
                public void onDataChange(DataSnapshot dataSnapshot) {
                    if (!dataSnapshot.hasChildren()){   //nouvelle discussion
                        HashMap<String, String> carteDeH = new HashMap<>();
                        carteDeH.put("utilisateur1", result.getContents());
                        carteDeH.put("utilisateur2", firebaseUser.getUid());
                        databaseReference.setValue(carteDeH);
                    }
                    FirebaseDatabase.getInstance("https://vidar-9e8ac-default-rtdb.europe-west1.firebasedatabase.app").getReference().child("Users").child(result.getContents()).child("contact").setValue(firebaseUser.getUid());
                    Intent intention = new Intent(MainActivity.this,ActiviteDiscussion.class);
                    intention.putExtra("id",result.getContents());
                    intention.putExtra("dis",firebaseUser.getUid()+result.getContents());
                    startActivity(intention);
                    finish();
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    // Getting Post failed, log a message
                    Log.w(TAG, "loadPost:onCancelled", databaseError.toException());
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