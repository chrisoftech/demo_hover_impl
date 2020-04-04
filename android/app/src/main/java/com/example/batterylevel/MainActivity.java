package com.example.batterylevel;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import android.content.Intent;
import android.os.Bundle;

import java.util.HashMap;
import java.util.Map;

import com.hover.sdk.api.Hover;
import com.hover.sdk.api.HoverParameters;

import io.flutter.Log;

// import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.room.Transaction;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL_HOVER = "samples.flutter.dev/hover";

    private void sendMoneyToIndividual(String phoneNumber, String amount, String reference) {
        try {
            Hover.initialize(this);
            Log.d("MainActivity", "Sims are = " + Hover.getPresentSims(this));
            Log.d("MainActivity", "Hover actions are = " + Hover.getAllValidActions(this));
        } catch (Exception e) {
            Log.e("MainActivity", "hover exception", e);
        }

        // add your action Id from dashboard
        Intent i = new HoverParameters.Builder(this).request("bda41360").extra("phoneNumber", phoneNumber)
                .extra("confirmPhoneNumber", phoneNumber).extra("amount", amount).extra("reference", reference)
                .buildIntent();

        startActivityForResult(i, 0);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_HOVER)
                .setMethodCallHandler((call, result) -> {
                    // Note: this method is invoked on the main thread.
                    if (call.method.equals("sendMoneyToIndividual")) {
                        final Map<String, Object> arguments = call.arguments();
                        String phoneNumber = (String) arguments.get("phoneNumber");
                        String amount = (String) arguments.get("amount");
                        String reference = (String) arguments.get("reference");

                        sendMoneyToIndividual(phoneNumber, amount, reference);

                        // Get json string from intent in TransactionReciever
                        Intent intent = getIntent();
                        String jsonResult = intent.getStringExtra(TransactionReceiver.HOVER_TRANSACTION);


                        Log.d("HOVER_TRANSACTION", "Json result from main activity" + jsonResult);

                        // String response = "sent";
                        result.success(jsonResult);
                    } else {
                        result.notImplemented();
                    }
                });
    }
}