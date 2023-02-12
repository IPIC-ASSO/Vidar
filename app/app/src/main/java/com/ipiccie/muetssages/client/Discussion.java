package com.ipiccie.muetssages.client;

import java.util.HashMap;

public class Discussion {
    private String utilisateur1;
    private String utilisateur2;
    private String supr;
    private HashMap<String,HashMap<String,String>> messages;

    public Discussion(String utilisateur1, String utilisateur2) {
        this.utilisateur1 = utilisateur1;
        this.utilisateur2 = utilisateur2;
    }

    public Discussion(String utilisateur1, String utilisateur2, String supr) {
        this.utilisateur1 = utilisateur1;
        this.utilisateur2 = utilisateur2;
        this.supr = supr;
    }

    public Discussion(){

    }

    public String getUtilisateur1() {
        return utilisateur1;
    }

    public void setUtilisateur1(String utilisateur1) {
        this.utilisateur1 = utilisateur1;
    }

    public String getUtilisateur2() {
        return utilisateur2;
    }

    public void setUtilisateur2(String utilisateur2) {
        this.utilisateur2 = utilisateur2;
    }

    public HashMap<String,HashMap<String,String>> getMessages() {
        return messages;
    }

    public void setMessages(HashMap<String,HashMap<String,String>> messages) {
        this.messages = messages;
    }
    public String getSupr() {
        return supr;
    }
    public void setSupr(String supr) {
        this.supr = supr;
    }
}
