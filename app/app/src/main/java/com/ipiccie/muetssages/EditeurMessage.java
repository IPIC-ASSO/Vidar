package com.ipiccie.muetssages;

import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.speech.tts.TextToSpeech;
import android.text.InputType;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;

import java.util.Locale;
import java.util.Objects;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link EditeurMessage#newInstance} factory method to
 * create an instance of this fragment.
 */
public class EditeurMessage extends Fragment {

    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    public EditeurMessage() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment EditeurMessage.
     */
    // TODO: Rename and change types and number of parameters
    public static EditeurMessage newInstance(String param1, String param2) {
        EditeurMessage fragment = new EditeurMessage();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ActionBar ab = ((AppCompatActivity) getActivity()).getSupportActionBar();
        SharedPreferences prefs =this.getActivity().getBaseContext().getSharedPreferences("classes", Context.MODE_PRIVATE);//liste des intitulés et message associé
        String intitule;
        EditText inti = view.findViewById(R.id.intitule);
        EditText msg = view.findViewById(R.id.texte_message);
        if(ab != null){
            ab.setDisplayHomeAsUpEnabled(true);
        }
        if (getArguments() != null &&!Objects.equals(getArguments().getString("intitulé"), "inconnu au bataillon")) {
            intitule = getArguments().getString("intitulé");
            if (Objects.equals(intitule, "message par defaut")){
                inti.setInputType(InputType.TYPE_NULL);
            }
            inti.setText(intitule);
            msg.setText(prefs.getString(intitule,""));
        }
        view.findViewById(R.id.enregistre_msg).setOnClickListener(v->{
            if(!inti.getText().toString().equals("") && !msg.getText().toString().equals("")){
                prefs.edit().putString(inti.getText().toString(),msg.getText().toString()).apply();
                findNavController(this).navigate(R.id.action_editeurMessage_to_listeMessages);
            }else{
                Toast.makeText(this.getContext(),"Veuillez remplir tous les champs",Toast.LENGTH_SHORT).show();
            }
        });
        view.findViewById(R.id.supr_msg).setOnClickListener(v->{
            if (!inti.getText().toString().equals("") && prefs.getAll().containsKey(inti.getText().toString())){
                prefs.edit().remove(inti.getText().toString()).apply();
            }
            findNavController(this).navigate(R.id.action_editeurMessage_to_listeMessages);
        });
        TextToSpeech textToSpeech = new TextToSpeech(this.getContext(), status -> {

        });
        textToSpeech.setLanguage(Locale.FRANCE);
        textToSpeech.setSpeechRate(1.3F);
        view.findViewById(R.id.lecteur_messages_editeur).setOnClickListener(w-> {
            textToSpeech.speak(msg.getText().toString(),TextToSpeech.QUEUE_FLUSH,null);
            Toast.makeText(this.getContext(),"Lecture en cours",Toast.LENGTH_SHORT).show();
        });
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
        return inflater.inflate(R.layout.fragment_editeur_message, container, false);
    }
}