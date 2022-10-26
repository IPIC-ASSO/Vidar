package com.ipiccie.muetssages.client;

public class Chat {

    private String envoyeur;
    private String message;

    public Chat(String envoyeur, String destinataire, String message){
        this.message = message;
        this.envoyeur = envoyeur;
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
}
