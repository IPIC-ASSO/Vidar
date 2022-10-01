package com.ipiccie.muetssages;

import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link ListeMessages#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ListeMessages extends Fragment {

    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    public ListeMessages() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment ListeMessages.
     */
    // TODO: Rename and change types and number of parameters
    public static ListeMessages newInstance(String param1, String param2) {
        ListeMessages fragment = new ListeMessages();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.findViewById(R.id.nouveau_message).setOnClickListener(w->{
            Bundle bundle = new Bundle();
            bundle.putString("intitulé", "inconnu au bataillon");
            findNavController(this).navigate(R.id.action_listeMessages_to_editeurMessage,bundle);
        });
        inflation();
        ActionBar ab = ((AppCompatActivity) getActivity()).getSupportActionBar();
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_liste_messages, container, false);
    }

    public void inflation(){
        SharedPreferences prefs =this.getActivity().getBaseContext().getSharedPreferences("classes", Context.MODE_PRIVATE);//liste des intitulés et message associé
        if(prefs.getAll().keySet().isEmpty()){
            prefs.edit().putString("message par defaut", "Bonjour, pour communiquer plus facilement, je vous propose d'utiliser une application de messagerie instantanée").apply();
        }else{
            this.getView().findViewById(R.id.instruc_liste_msg).setVisibility(View.INVISIBLE);
        }
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        params.setMargins(2,5, 2,5);
        LinearLayout liste = this.getView().findViewById(R.id.liste_messages);
        int stylebouton = com.google.android.material.R.style.Widget_MaterialComponents_Button_OutlinedButton;
        for (String intitule:prefs.getAll().keySet()){
            Button txt = new Button(new ContextThemeWrapper(this.getContext(),stylebouton), null, stylebouton);
            txt.setText(intitule);
            txt.setBackgroundColor(Color.parseColor("#DDDDDD"));
            txt.setLayoutParams(params);
            liste.addView(txt);
            txt.setOnClickListener(w->{
                Bundle bundle = new Bundle();
                bundle.putString("intitulé", intitule);
                findNavController(this).navigate(R.id.action_listeMessages_to_editeurMessage,bundle);
            });
        }
    }
}