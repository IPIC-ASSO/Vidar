package com.ipiccie.muetssages.client;



import static android.content.ContentValues.TAG;

import android.util.Log;


public class Utilisateur {
    private String id;
    private String username;
    private String imageURL;
    private String contact;

    public Utilisateur(String id, String imageURL,  String username, String contact){
        this.id = id;
        this.username = username;
        this.imageURL = imageURL;
        this.contact = contact;
        Log.d(TAG,"Utilisateur: "+contact);
    }

    public Utilisateur(){
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public String getContact() {
        Log.d(TAG,"Utilisateur: "+contact);
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }
}
