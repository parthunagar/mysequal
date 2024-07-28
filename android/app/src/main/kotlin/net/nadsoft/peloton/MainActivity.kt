package net.nadsoft.peloton

import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant



class MainActivity: FlutterActivity() {

    private val authenticateChannel = "com.neura.flutterApp/authenticate"
    private val TAG = ""
    private var mNeuraHelper: NeuraHelper? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        print("did init")
        Log.d("MainActivity","did init2")
    }
    fun getFlutterView(): BinaryMessenger? {
        return flutterEngine?.dartExecutor?.binaryMessenger
    }

    

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //GeneratedPluginRegistrant.registerWith(this);
        mNeuraHelper = NeuraHelper(this)
        MethodChannel(getFlutterView(),authenticateChannel).setMethodCallHandler {
            call, result -> mNeuraHelper!!.authenticateAnonymously(result)
        }
    }
}
