package com.ipiccie.muetssages.client;

import com.google.firebase.database.FirebaseDatabase;

public class BaseDeFeu extends android.app.Application {

    @Override
    public void onCreate() {
        super.onCreate();
        FirebaseDatabase.getInstance().setPersistenceEnabled(true);
    }
}