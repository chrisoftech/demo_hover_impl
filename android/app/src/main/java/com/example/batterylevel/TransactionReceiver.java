package com.example.batterylevel;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

public class TransactionReceiver extends BroadcastReceiver {
    public TransactionReceiver() {
    }

    static final String HOVER_TRANSACTION = "hover_transaction";

    static String amount = "";
    static String currentBalance = "";
    static String availableBalance = "";
    static String reference = "";
    static String transactionId = "";
    static String feeCharged = "";

    @Override
    public void onReceive(Context context, Intent intent) {
        String uuid = intent.getStringExtra("uuid");


        JSONObject transactionStatusJson = new JSONObject();

        if (intent.hasExtra("parsed_variables")) {
            Log.d("parsed_variables", "Passed Variables is true");

            HashMap<String, String> parsed_variables = (HashMap<String, String>) intent
                    .getSerializableExtra("parsed_variables");

            if (parsed_variables.containsKey("amount"))
                amount = parsed_variables.get("amount");
            if (parsed_variables.containsKey("currentBalance"))
                currentBalance = parsed_variables.get("currentBalance");
            if (parsed_variables.containsKey("availableBalance"))
                availableBalance = parsed_variables.get("availableBalance");
            if (parsed_variables.containsKey("reference"))
                reference = parsed_variables.get("reference");
            if (parsed_variables.containsKey("transactionId"))
                transactionId = parsed_variables.get("transactionId");
            if (parsed_variables.containsKey("feeCharged"))
                feeCharged = parsed_variables.get("feeCharged");

            // create json string
            try {
                transactionStatusJson.put("STATUS", intent.getStringExtra("status"));
                transactionStatusJson.put("AMOUNT", amount);
                transactionStatusJson.put("CURRENT_BALANCE", currentBalance);
                transactionStatusJson.put("AVAILABLE_BALANCE", availableBalance);
                transactionStatusJson.put("REFERENCE", reference);
                transactionStatusJson.put("TRANSACTION_ID", transactionId);
                transactionStatusJson.put("FEE_CHARGED", feeCharged);

            } catch (JSONException e) {
                e.printStackTrace();
            }

            Log.d("HOVER_TRANSACTION", transactionStatusJson.toString());

            Intent activityIntent = new Intent(context, MainActivity.class);
            activityIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activityIntent.putExtra(HOVER_TRANSACTION, transactionStatusJson.toString());
            context.startActivity(activityIntent);
        } else {
            try {
                transactionStatusJson.put("STATUS", intent.getStringExtra("status"));
                transactionStatusJson.put("MESSAGE", intent.getStringExtra("status_description"));
            } catch (JSONException e) {
                e.printStackTrace();
            }

            Intent activityIntent = new Intent(context, MainActivity.class);
            activityIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activityIntent.putExtra(HOVER_TRANSACTION, transactionStatusJson.toString());
            context.startActivity(activityIntent);
        }
    }
}
