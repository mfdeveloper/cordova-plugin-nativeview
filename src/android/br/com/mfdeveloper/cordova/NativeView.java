package br.com.mfdeveloper.cordova;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.util.Log;

import org.apache.cordova.BuildConfig;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * Start a native Activity. This plugin
 * use Java Reflection to decide which method
 * execute
 *
 * Based and inspired by cordova plugin: com.lampa.startapp
 *
 * @author @mfdeveloper on 28/08/17
 * @see https://github.com/lampaa/com.lampa.startapp
 */
public class NativeView extends CordovaPlugin {

    private static final String TAG = "NativeViewPlugin";
    protected HashMap<String, String> marketUrls = new HashMap<String, String>() {{
        put("app", "market://details?id=%s");
        put("web", "https://play.google.com/store/apps/details?id=%s");
    }};

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        Log.d(TAG, "Initializing " + TAG);
    }

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) {

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

    public void show(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        JSONObject activityParams = mountParams(args);


        final Intent intentToStart = configureIntent(args, activityParams, callbackContext);

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {

                try {
                    /**
                     * Reference: You can use "PendingIntent" to avoid open the Activity twice,
                     * but the ActivityNotFound exception is never catch
                     *
                     * @see https://www.journaldev.com/10463/android-notification-pendingintent
                     */
                    cordova.getActivity().startActivity(intentToStart);
                    JSONObject success = new JSONObject();
                    success.put("success", true);
                    success.put("message", "Native screen is started");

                    callbackContext.success(success);
                } catch (Exception e) {

                    JSONObject error = errorResult(e);
                    callbackContext.error(error);
                    e.printStackTrace();
                }

            }
        });
    }

    public void showMarket(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        JSONObject activityParams = mountParams(args);
        String targetPackage;

        if (activityParams.has("marketId")) {
            targetPackage = activityParams.getString("marketId");
        }else{

            targetPackage = activityParams.has("package") ? activityParams.optString("package") : activityParams.optString("packageApp");
        }

        final Intent intent = new Intent(Intent.ACTION_VIEW);

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    intent.setData(Uri.parse(String.format(marketUrls.get("app"), targetPackage)));
                    cordova.getActivity().startActivity(intent);
                } catch (ActivityNotFoundException activityErr) {

                    try {
                        intent.setData(Uri.parse(String.format(marketUrls.get("web"), targetPackage)));
                        cordova.getActivity().startActivity(intent);
                    }catch (Exception err) {
                        JSONObject error = errorResult(err);
                        callbackContext.error(error);
                        err.printStackTrace();
                    }
                }catch (Exception e) {

                    JSONObject error = errorResult(e);
                    callbackContext.error(error);
                    e.printStackTrace();
                }
            }
        });
    }

    public void checkIfAppInstalled(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        JSONObject activityParams = mountParams(args);
        Intent intent = configureIntent(args, activityParams, callbackContext);

        PackageManager packManager = this.cordova.getActivity().getApplicationContext().getPackageManager();

        // Get all activities that respond to the configured Intent (by uri, package etc..)
        List<ResolveInfo> listInfo = packManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);

        if (listInfo.size() > 0) {

            JSONObject result = new JSONObject() {{
                put("success", true);
                put("packageName", listInfo.get(0).activityInfo.packageName);
                put("applicationInfo", listInfo.get(0).activityInfo.toString());
                put("activityName", listInfo.get(0).activityInfo.name);
            }};

            callbackContext.success(result);

        }else{
            JSONObject error = new JSONObject() {{
                put("success", false);
                put("message", "App not found");
                put("intent", intent.toString());
                put("action", intent.getAction());
                put("params", activityParams);
            }};
            callbackContext.error(error);
        }
    }

    public void getBuildVariant(JSONArray args, final CallbackContext callbackContext) {

        if (args.length() > 0) {

            try{

                JSONObject params = args.getJSONObject(0);

                if (params.has("catchError") && params.optBoolean("catchError", true)) {

                    if (BuildConfig.FLAVOR == null || BuildConfig.FLAVOR.length() == 0) {

                        JSONObject error = new JSONObject();
                        error.put("success", false);
                        error.put("message", "The FLAVOR is not defined. Verify your build.gradle 'productFlavors' config");

                        callbackContext.error(error);
                        return;
                    }
                }

            }catch (JSONException e) {
                JSONObject error = errorResult(e);

                callbackContext.error(error);
            }
        }


        callbackContext.success(BuildConfig.FLAVOR);
    }

    protected JSONObject mountParams(JSONArray args) throws JSONException {

        JSONObject activityParams;

        if (args.opt(0) instanceof JSONObject) {
            activityParams = new JSONObject(args.getJSONObject(0).toString());
        }else {
            activityParams = new JSONObject();
            activityParams.put("packageName", args.optString(0));
            activityParams.put("className", args.optString(1));
        }

        return activityParams;
    }

    protected Intent configureIntent(JSONArray args, JSONObject activityParams, CallbackContext callbackContext) throws JSONException {
        Intent intent = new Intent();

        intent = intentFromUri(intent, activityParams, callbackContext)
                .intentFromClass(intent, activityParams, callbackContext);

        String targetPackage = activityParams.has("package") ? activityParams.optString("package") : activityParams.optString("packageApp");

        if (targetPackage != null) {

            intent.setPackage(targetPackage);
        }

        intent = intentFromComponent(intent, activityParams, callbackContext);

        addFlags(intent, activityParams, callbackContext);

        addExtraParams(args, activityParams, intent);
        return intent;
    }

    protected Intent intentFromComponent(Intent intent, JSONObject activityParams, CallbackContext callbackContext) throws JSONException {

        if(activityParams.has("component")) {
            JSONObject component = activityParams.getJSONObject("component");

            if(component.has("packageApp") && component.has("className")) {
                if (!component.getString("className").startsWith(".")) {
                    component.put("className", component.getString("packageApp") + "." + component.getString("className"));
                }
                intent.setComponent(new ComponentName(component.getString("packageApp"), component.getString("className")));
            } else {

                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", "The 'component' key needs contains 'packageApp' and 'className' args");

                callbackContext.error(error);
                throw new RuntimeException(error.getString("message"));
            }
        }
        return intent;
    }

    protected NativeView intentFromUri(Intent intent, JSONObject activityParams, CallbackContext callbackContext) throws JSONException {

        if(activityParams.has("uri")) {

            String action = Intent.ACTION_VIEW;

            if (activityParams.has("action")) {
                try{
                    action = (String) getIntentValue(activityParams.optString("action"));
                }catch (Exception intentErr) {
                    JSONObject error = errorResult(intentErr);
                    callbackContext.error(error);

                    intentErr.printStackTrace();
                }
            }

            intent.setAction(action);
            intent.setData(Uri.parse(activityParams.getString("uri")));
        }

        return this;
    }

    protected Intent intentFromClass(Intent intent, JSONObject activityParams, CallbackContext callbackContext) throws JSONException {

        if (activityParams.has("className")) {

            Activity activity = null;

            if (!activityParams.has("packageName")
                || activityParams.getString("packageName").contains(cordova.getActivity().getPackageName())) {
               activity = cordova.getActivity();
            }

            if(activity != null) {
                try {

                    Class<?> activityClass = Class.forName(activityParams.getString("packageName") + "." + activityParams.getString("className"));
                    intent = new Intent(activity, activityClass);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

                }catch (Exception clsErr) {
                    JSONObject error = errorResult(clsErr);

                    callbackContext.error(error);
                    clsErr.printStackTrace();
                }
            }else{
                ComponentName component = new ComponentName(activityParams.getString("packageName"), activityParams.getString("className"));
                intent = new Intent().setComponent(component);
            }
        }
        return intent;
    }

    protected void addFlags(Intent intent, JSONObject activityParams, final CallbackContext callbackContext) {


        JSONArray flags = activityParams.optJSONArray("flags");

        if (flags == null) {
            flags = new JSONArray();
        }

        // Add default flags
        flags.put(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        for(int i=0; i < flags.length(); i++) {
            int flagValue;
            try{

                if (flags.get(i) instanceof String) {
                    flagValue = (int) getIntentValue(flags.getString(i));
                }else{
                    flagValue = flags.getInt(i);
                }

                intent.addFlags(flagValue);
            }catch (Exception intentErr) {
                JSONObject error = errorResult(intentErr);
                callbackContext.error(error);
            }
        }

    }

    protected void addExtraParams(JSONArray args, JSONObject activityParams, Intent intent) throws JSONException {
        JSONObject jsonExtra;
        if (activityParams.opt("className") instanceof JSONObject) {
            jsonExtra = activityParams.getJSONObject("className");
        } else {

            if (args.length() == 2 && args.opt(0) instanceof JSONObject) {
                jsonExtra = args.optJSONObject(1);
            }else{

                jsonExtra = args.length() >= 3 ? args.getJSONObject(2) : activityParams.optJSONObject("params");
            }

        }

        if (jsonExtra != null) {

            Iterator<?> keys = jsonExtra.keys();

            while (keys.hasNext()) {
                String key = (String) keys.next();
                Object value = jsonExtra.get(key);

                if(value instanceof Integer) {
                    intent.putExtra(key, jsonExtra.getInt(key));
                }

                if(value instanceof String) {
                    intent.putExtra(key, jsonExtra.getString(key));
                }

                if(value instanceof Boolean) {
                    intent.putExtra(key, jsonExtra.getBoolean(key));
                }
            }
        }
    }

    protected JSONObject errorResult(Exception e) {
        HashMap<String, Object> data = new HashMap<String, Object>();
        data.put("success", false);
        data.put("name", e.getClass().getName());
        data.put("message", e.getMessage() != null ? e.getMessage() : e.getCause().getMessage());

        JSONObject error = new JSONObject(data);
        return error;
    }

    protected JSONObject errorResult(Exception e, HashMap<String, Object> extraData) {
        HashMap<String, Object> data = new HashMap<String, Object>();
        data.put("success", false);
        data.put("name", e.getClass().getName());
        data.put("message", e.getMessage() != null ? e.getMessage() : e.getCause().getMessage());

        data.putAll(extraData);

        JSONObject error = new JSONObject(data);
        return error;
    }

    protected Object getIntentValue(String flag) throws NoSuchFieldException, IllegalAccessException {
        Field field = Intent.class.getDeclaredField(flag);
        field.setAccessible(true);

        return field.get(null);
    }
}
