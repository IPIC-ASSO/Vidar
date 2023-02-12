package com.ipiccie.muetssages.notifications;

public class Envoyeur {
    private donnees donnees;
    private String destinataire;

    public Envoyeur(com.ipiccie.muetssages.notifications.donnees donnees, String destinataire) {
        this.donnees = donnees;
        this.destinataire = destinataire;
    }
}
