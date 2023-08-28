package com.ipiccie.muetssages.notifications;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Icon;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.core.app.NotificationCompat;
import androidx.fragment.app.strictmode.FragmentStrictMode;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.messaging.CommonNotificationBuilder;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.ipiccie.muetssages.ActiviteDiscussion;
import com.ipiccie.muetssages.R;

import java.util.Objects;

public class MonMessager extends FirebaseMessagingService {
    @Override
    public void onMessageReceived(@NonNull RemoteMessage message) {
        super.onMessageReceived(message);

        String envoye = message.getData().get("envoye");
        FirebaseUser utilisateur = FirebaseAuth.getInstance().getCurrentUser();
        if (utilisateur!= null && Objects.equals(envoye, utilisateur.getUid())){
            sendNotification(message);
        }
    }

    private void sendNotification(RemoteMessage message) {
        String uti = message.getData().get("utilisateur");  //auteur du message envoyé en notif
        String titre = message.getData().get("titre");
        String corps = message.getData().get("corps");
        int j = Integer.parseInt(Objects.requireNonNull(uti).replaceAll("[\\D]",""));
        RemoteMessage.Notification notifications = message.getNotification();
        Intent intention = new Intent(this, ActiviteDiscussion.class);
        Bundle sac = new Bundle();
        sac.putString("id",uti);
        PendingIntent IntentionEnAttente = PendingIntent.getActivity(this, j, intention, PendingIntent.FLAG_ONE_SHOT);
        NotificationCompat.Builder constructeur = new NotificationCompat.Builder(this)
                .setContentTitle(titre)
                .setContentText(corps)
                .setAutoCancel(true)
                .setContentIntent(IntentionEnAttente);
        NotificationManager notifie = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        int i = Math.max(j, 0);
        notifie.notify(i, constructeur.build());

    }
}
