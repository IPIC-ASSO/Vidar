package com.ipiccie.muetssages.client;



import android.util.Log;

import java.util.List;

public class Utilisateur {
    private String id;
    private String username;
    private String imageURL;
    private List<String> contacts;

    public Utilisateur(String id, String imageURL,  String username, List<String> contacts){
        this.id = id;
        this.username = username;
        this.imageURL = imageURL;
        this.contacts = contacts;
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

    public List<String> getContacts() {
        return contacts;
    }

    public void setContacts(List<String> contacts) {
        this.contacts = contacts;
    }
}
