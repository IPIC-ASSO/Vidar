package com.ipiccie.muetssages.notifications;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Headers;
import retrofit2.http.POST;

public interface APIService {
    @Headers(
            {
                    "Content-Type:application/json",
                    "Authorization:key=ddd"
            }
    )

    @POST("fcm/send")
    Call<MaReponse> sendNotification(@Body Envoyeur corps );
}
