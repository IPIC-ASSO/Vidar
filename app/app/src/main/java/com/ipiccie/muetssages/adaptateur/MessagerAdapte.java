package com.ipiccie.muetssages.adaptateur;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.ipiccie.muetssages.ActiviteDiscussion;
import com.ipiccie.muetssages.R;
import com.ipiccie.muetssages.client.Chat;

import java.util.List;

public class MessagerAdapte extends RecyclerView.Adapter<MessagerAdapte.ViewHolder> {

    private final Context context;
    private final List<Chat> listeDeChats;
    private static final int MESSAGE_TYPE_DROIT = 1;


    public MessagerAdapte(@NonNull Context context, List<Chat>listeDeChats) {
        this.context = context;
        this.listeDeChats = listeDeChats;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view;
        if (viewType == MESSAGE_TYPE_DROIT){
            view = LayoutInflater.from(context).inflate(R.layout.message_droitier, parent,false);
        }else{
            view = LayoutInflater.from(context).inflate(R.layout.message_gauchiste, parent,false);
        }
        if (context instanceof ActiviteDiscussion){
            TextView txt = view.findViewById(R.id.texte_message_dis);
            view.setOnClickListener(x -> ((ActiviteDiscussion) context).popUp(txt.getText().toString()));
        }
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Chat chaton = listeDeChats.get(position);
        holder.texteMessage.setText(chaton.getMessage());
    }

    @Override
    public int getItemCount() {
        return listeDeChats.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder{
        private final TextView texteMessage;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            texteMessage = itemView.findViewById(R.id.texte_message_dis);
        }

    }

    @Override
    public int getItemViewType(int position) {
        int MESSAGE_TYPE_GAUCHE = 0;
        FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
        if (firebaseUser != null) {
            if (listeDeChats.get(position).getEnvoyeur().equals(firebaseUser.getUid())){
                return MESSAGE_TYPE_DROIT;
            }else{

                return MESSAGE_TYPE_GAUCHE;
            }
        }
        return MESSAGE_TYPE_GAUCHE;
    }
}
