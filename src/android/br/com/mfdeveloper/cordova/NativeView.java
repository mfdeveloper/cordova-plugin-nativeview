package br.com.mfdeveloper.cordova;

import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;

/**
 * Start a native Activity. This plugin
 * use Java Reflection to decide which method
 * execute
 *
 * @author @mfdeveloper on 28/08/17
 */
public class NativeView extends CordovaPlugin {

    private static final String TAG = "NativeViewPlugin";

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        Log.d(TAG, "Initializing " + TAG);
    }

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

        try {

            Method method = getClass().getMethod(action, JSONArray.class, CallbackContext.class);

            try {

                method.invoke(this, args, callbackContext);

                return true;

            } catch (IllegalAccessException e) {
                JSONObject error = errorResult(e);
                callbackContext.error(error);

                e.printStackTrace();

            } catch (IllegalArgumentException e) {
                JSONObject error = errorResult(e);
                callbackContext.error(error);

                e.printStackTrace();

            }catch (InvocationTargetException e) {
                JSONObject error = errorResult(e);
                callbackContext.error(error);

                e.printStackTrace();
            }
        }catch (NoSuchMethodException e) {

            String message = String.format("Method with name: %s was not found on: %s\n Reason: %s", action, getClass().getName(), e.getMessage());

            Log.d(TAG, message);

            HashMap<String, Object> data = new HashMap<String, Object>();
            data.put("message", message);

            JSONObject error = errorResult(e, data);
            callbackContext.error(error);

            e.printStackTrace();

        }

        return false;
    }

    public void show(JSONArray params, final CallbackContext callbackContext) throws JSONException {
        String packageName = params.getString(0);
        String className = params.getString(1);
        String extraParams;

        if (className.startsWith("{")) {
              extraParams = className;
        } else {

            extraParams = params.length() >= 3 ? params.getString(2) : null;
        }

        final Intent intent = new Intent(packageName.toLowerCase() + "." + className);

        if (extraParams != null) {

            JSONObject jsonExtra = new JSONObject(extraParams);
            Iterator<?> keys = jsonExtra.keys();

            while (keys.hasNext()) {
                String key = (String) keys.next();
                intent.putExtra(key, jsonExtra.getString(key));
            }
        }

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {

                try {
                    cordova.getActivity().startActivity(intent);
                    JSONObject success = new JSONObject();
                    success.put("success", true);

                    callbackContext.success(success);
                } catch (Exception e) {

                    JSONObject error = errorResult(e);
                    callbackContext.error(error);
                    e.printStackTrace();
                }

            }
        });
    }

    protected JSONObject errorResult(Exception e) {
        HashMap<String, Object> data = new HashMap<String, Object>();
        data.put("success", false);
        data.put("name", e.getClass().getName());
        data.put("message", e.getMessage());

        JSONObject error = new JSONObject(data);
        return error;
    }

    protected JSONObject errorResult(Exception e, HashMap<String, Object> extraData) {
        HashMap<String, Object> data = new HashMap<String, Object>();
        data.put("success", false);
        data.put("name", e.getClass().getName());
        data.put("message", e.getMessage());

        data.putAll(extraData);

        JSONObject error = new JSONObject(data);
        return error;
    }
}
