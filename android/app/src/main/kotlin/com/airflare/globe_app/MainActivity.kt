package com.airflare.globe_app

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.SplashScreen
import java.util.*

class MainActivity: FlutterActivity() {

//    override fun provideSplashScreen(): SplashScreen? = SplashView()


    override fun getDartEntrypointFunctionName(): String {
        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
            if (!task.isSuccessful) {
//                Log.w("discrete", "Fetching FCM registration token failed", task.exception)
                return@OnCompleteListener
            }

            // Get new FCM registration token
            val token = task.result
//            Log.w("discrete", "FCM registration token:"+token.toString())
        })
        return super.getDartEntrypointFunctionName()
    }

}
