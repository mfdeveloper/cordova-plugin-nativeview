package br.com.mfdeveloper.cordova.viewmodel

import android.app.Activity
import androidx.lifecycle.ViewModel
import br.com.mfdeveloper.cordova.NativeView
import org.json.JSONArray
import org.json.JSONObject

class NativeViewModel : ViewModel() {

    fun open(activity: Activity) {

        val params = JSONObject()
        params
            .put("packageName", "br.com.mfdeveloper.cordova.view")
            .put("className", "OtherActivity")

        //TODO: Refactor show() method to execute outside cordova app
        val nativeView = NativeView.getInstance(activity)
        nativeView.show(params)
    }
}