package com.ipiccie.muetssages.client;

public class Chat {

    private String envoyeur;
    private String destinataire;
    private String message;

    public Chat(String envoyeur, String destinataire, String message){
        this.message = message;
        this.destinataire = destinataire;
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

    public String getDestinataire() {
        return destinataire;
    }

    public void setDestinataire(String destinataire) {
        this.destinataire = destinataire;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
