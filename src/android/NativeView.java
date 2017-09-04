package br.com.mfdeveloper.cordova;

import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * Created by @mfdeveloper on 28/08/17.
 */

public class NativeView extends CordovaPlugin {

    private static final String TAG = "NativeViewPlugin";

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        Log.d(TAG, "Initializing NativeViewPlugin");
    }

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

        try {

            Method method = getClass().getMethod(action, JSONArray.class, CallbackContext.class);

            try {

                method.invoke(this, args, callbackContext);

                return true;

            } catch (IllegalAccessException e) {
                e.printStackTrace();

            } catch (IllegalArgumentException e) {
                e.printStackTrace();

            }catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }catch (NoSuchMethodException e) {

            String message = String.format("Method with name: %s was not found on: %s\n Reason: %s", action, getClass().getName(), e.getMessage());

            Log.d(TAG, message);

            e.printStackTrace();

        }

        return false;
    }

    public void show(JSONArray params, final CallbackContext callbackContext) throws JSONException {
        String packageName = params.getString(0);
        String className = params.getString(1);

        final Intent intent = new Intent(packageName.toLowerCase() + "." + className);

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                cordova.getActivity().startActivity(intent);

                callbackContext.success("started");
            }
        });
    }
}
