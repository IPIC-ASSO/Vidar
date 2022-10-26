package com.ipiccie.muetssages.adaptateur;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.ipiccie.muetssages.ActiviteDiscussion;
import com.ipiccie.muetssages.R;
import com.ipiccie.muetssages.client.Utilisateur;

import java.util.List;

public class AdaptateurAdapte extends RecyclerView.Adapter<AdaptateurAdapte.ViewHolder> {

    private Context context;
    private List<Utilisateur> mUtilisateurs;
    private List<String> idConversations;


    public AdaptateurAdapte(@NonNull Context context, List<Utilisateur>mUtilisateurs, List<String> idConversations) {
        this.context = context;
        this.mUtilisateurs = mUtilisateurs;
        this.idConversations = idConversations;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.profil_conv, parent,false);
        return new AdaptateurAdapte.ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Utilisateur utilisateur = mUtilisateurs.get(position);
        holder.nomUtilisateur.setText(utilisateur.getUsername());
        if (utilisateur.getImageURL().equals("defaut")){
            holder.profileImage.setImageResource(R.drawable.ic_launcher_foreground);
        }
        holder.itemView.setOnClickListener(v->{
            Intent intention = new Intent(context,ActiviteDiscussion.class);
            intention.putExtra("dis",idConversations.get(position));
            intention.putExtra("id",utilisateur.getId());
            context.startActivity(intention);
        });
    }

    @Override
    public int getItemCount() {
        return mUtilisateurs.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder{
        public TextView nomUtilisateur;
        public ImageView profileImage;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            nomUtilisateur = itemView.findViewById(R.id.utilisateur_conv);
            profileImage = itemView.findViewById(R.id.image_profile);

        }

    }

}
