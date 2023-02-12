package com.ipiccie.muetssages.notifications;

public class donnees {
    private String titre;
    private String message;
    private String utilisateur;
    private String idDiscussion;
    private String envoye;

    public donnees(String titre, String message, String utilisateur, String idDiscussion, String envoye) {
        this.titre = titre;
        this.message = message;
        this.utilisateur = utilisateur;
        this.envoye = envoye;
        this.idDiscussion = idDiscussion;
    }


    public String getUtilisateur() {
        return utilisateur;
    }

    public void setUtilisateur(String utilisateur) {
        this.utilisateur = utilisateur;
    }

    public String getEnvoye() {
        return envoye;
    }

    public void setEnvoye(String envoye) {
        this.envoye = envoye;
    }

    public String getIdDiscussion() {
        return idDiscussion;
    }

    public void setIdDiscussion(String idDiscussion) {
        this.idDiscussion = idDiscussion;
    }

    public String getTitre() {
        return titre;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
