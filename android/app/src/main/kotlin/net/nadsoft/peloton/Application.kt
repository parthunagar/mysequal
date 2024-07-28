package net.nadsoft.peloton;

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
import android.util.Log

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin




/*

class Application : FlutterApplication(), PluginRegistry.PluginRegistrantCallback  {
 override fun onCreate() {
  super.onCreate()
  FlutterFirebaseMessagingService.setPluginRegistrant(this)
 }
/*
 override fun registerWith(registry: PluginRegistry) {
   GeneratedPluginRegistrant.registerWith(registry)
  //FirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin")); 
  }
  */
     override fun registerWith(registry: PluginRegistry?) {
     //GeneratedPluginRegistrant.registerWith(registry);
     //registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin");
      io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
   }
}
*/


class Application : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {

    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
    }

    override fun registerWith(registry: PluginRegistry?) {
        if (registry != null) {
            FirebaseCloudMessagingPluginRegistrant.registerWith(registry)
            FlutterLocalNotificationPluginRegistrant.registerWith(registry)
        }
    }
    
}

class FirebaseCloudMessagingPluginRegistrant {
    companion object {
        fun registerWith(registry: PluginRegistry) {
            Log.d("FirebaseCloudMessaging", "registerWith");
            if (alreadyRegisteredWith(registry)) {
                Log.d("Already Registered","");
                return
            }
            try {
                FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
            } catch (e: Exception) {
                Log.d("FirebaseCloudMessaging", e.toString());
            }

            Log.d("Plugin Registered","");
        }

        private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
            val key = FirebaseCloudMessagingPluginRegistrant::class.java.canonicalName
            if (registry.hasPlugin(key)) {
                return true
            }
            registry.registrarFor(key)
            return false
        }
    }
}



class FlutterLocalNotificationPluginRegistrant {

    companion object {
        fun registerWith(registry: PluginRegistry) {
            if (alreadyRegisteredWith(registry)) {
                Log.d("Local Plugin", "Already Registered");
                return
            }
            FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))
            Log.d("Local Plugin", "Registered");
        }

        private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
            val key = FlutterLocalNotificationPluginRegistrant::class.java.canonicalName
            if (registry.hasPlugin(key)) {
                return true
            }
            registry.registrarFor(key)
            return false
        }
    }
}


