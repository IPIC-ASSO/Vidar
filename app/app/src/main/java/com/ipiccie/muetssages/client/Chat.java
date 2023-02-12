package com.ipiccie.muetssages.client;

public class Chat {

    private String envoyeur;
    private String message;

    private int rep;

    public Chat(String envoyeur, String message){
        this.message = message;
        this.envoyeur = envoyeur;
    }

    public Chat(String envoyeur, String message, int rep){
        this.message = message;
        this.envoyeur = envoyeur;
        this.rep = rep;
    }

    public Chat(){

    }

    public String getEnvoyeur() {
        return envoyeur;
    }

    public void setEnvoyeur(String envoyeur) {
        this.envoyeur = envoyeur;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public int getRep() {
        return rep;
    }

    public void setRep(int rep) {
        this.rep = rep;
    }
}
