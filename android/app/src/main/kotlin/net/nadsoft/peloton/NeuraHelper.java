package net.nadsoft.peloton;

import android.content.Context;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.neura.resources.authentication.AnonymousAuthenticateCallBack;
import com.neura.resources.authentication.AnonymousAuthenticateData;
import com.neura.resources.authentication.AnonymousAuthenticationStateListener;
import com.neura.sdk.object.AnonymousAuthenticationRequest;
import com.neura.standalonesdk.events.NeuraEvent;
import com.neura.standalonesdk.events.NeuraEventCallBack;
import com.neura.standalonesdk.events.NeuraPushCommandFactory;
import com.neura.standalonesdk.service.NeuraApiClient;
import com.neura.standalonesdk.util.SDKUtils;

import io.flutter.plugin.common.MethodChannel;

public class NeuraHelper {

    private static final String TAG = NeuraHelper.class.getSimpleName();

    private NeuraApiClient mNeuraApiClient;

    public NeuraHelper(Context context) {
        // Replace Place holders with your own Neura APP_ID and Neura APP_SECRET
        mNeuraApiClient = NeuraApiClient.getClient(context, "us-FjnKKOVyLWjXn2sDHkSLS_5lOb89AhgmKhKG86sNDCU", "BZwssLQH1ZRcj0CAIWAGKxpIuvdkZkrCm9YCeOOulF4");
    }

    public NeuraApiClient getClient() {
        return mNeuraApiClient;
    }



    public void authenticateAnonymously( MethodChannel.Result result) {

        if (!isMinVersion()) {
            result.success("verison to min");
            return;
        }

        if (mNeuraApiClient.isLoggedIn()) {
            result.success(mNeuraApiClient.getUserAccessToken());
            Log.i(TAG,  "logged in");
            return;
        }else{
            Log.i(TAG,  "not logged in");
        }

        //Get the FireBase Instance ID, we will use it to instantiate AnonymousAuthenticationRequest
        FirebaseInstanceId.getInstance().getInstanceId()
                .addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                    @Override
                    public void onComplete(@NonNull Task<InstanceIdResult> task) {

                        if (!task.isSuccessful()) {
                            Log.w(TAG, "getInstanceId failed", task.getException());
                            return;
                        }

                        // Get new Instance ID token
                        if (task.getResult() != null) {
                            String pushToken = task.getResult().getToken();

                            //Instantiate AnonymousAuthenticationRequest instance.
                            AnonymousAuthenticationRequest request = new AnonymousAuthenticationRequest(pushToken);

                            //Pass the AnonymousAuthenticationRequest instance and register a call back for success and failure events.


                            mNeuraApiClient.authenticate(request, new AnonymousAuthenticateCallBack() {
                                @Override
                                public void onSuccess(AnonymousAuthenticateData data) {
                                    //mNeuraApiClient.registerAuthStateListener(silentStateListener);
                                    result.success(mNeuraApiClient.getUserAccessToken() );
                                    Log.i(TAG,  data.mNeuraUserId);
                                    Log.i(TAG, "Successfully requested authentication with neura. ");

                                }

                                @Override
                                public void onFailure(int errorCode) {
                                   // mNeuraApiClient.unregisterAuthStateListener();
                                  //  result.success("Failed to authenticate with neura. ");
                                    Log.e(TAG, "Failed to authenticate with neura. " + "Reason : " + SDKUtils.errorCodeToString(errorCode));
                                }
                            });
                        } else {
                            Log.e(TAG, "Firebase task returned without result, cannot proceed with Authentication flow.");
                        }
                    }
                });

    }

    private static boolean isMinVersion() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;
    }


}
