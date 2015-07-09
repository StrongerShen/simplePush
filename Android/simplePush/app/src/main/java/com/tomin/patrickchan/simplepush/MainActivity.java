package com.tomin.patrickchan.simplepush;



import android.app.DownloadManager;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;

import android.os.Bundle;

import android.preference.PreferenceManager;

import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.AppCompatActivity;

import android.util.Log;

import android.view.View;

import android.widget.ProgressBar;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;


import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;


import java.util.HashMap;
import java.util.Map;
import java.util.logging.LogRecord;

public class MainActivity extends AppCompatActivity {

    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;
    private static final String TAG = "MainActivity";

    String mStrUrl = "http://10.0.1.14/api/simplePush/Android/DeviceRegister.php";
    String mStrUserName, mStrDeviceName, mStrDeviceToken;

    private BroadcastReceiver mRegistrationBroadcastReceiver;
    private ProgressBar mRegistrationProgressBar;
    private EditText mEdtUserName, mEdtDeviceName;
    private Button mBtnSubmit;
    private TextView mTxtShowInfo;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);



        mTxtShowInfo = (TextView)findViewById(R.id.txtShowInfo);
        mRegistrationProgressBar = (ProgressBar) findViewById(R.id.registrationProgressBar);
        mEdtUserName = (EditText)findViewById(R.id.edtUserName);
        mEdtDeviceName = (EditText)findViewById(R.id.edtDeviceName);
        mBtnSubmit = (Button)findViewById(R.id.btnSubmit);


        mBtnSubmit.setOnClickListener(btnSubmitOnClick);

        mRegistrationBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                mRegistrationProgressBar.setVisibility(ProgressBar.GONE);
                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(MainActivity.this);

                boolean sentToken = sharedPreferences
                        .getBoolean(QuickstartPreferences.SENT_TOKEN_TO_SERVER, false);
                if (sentToken) {
                    mBtnSubmit.setVisibility(View.VISIBLE);
                } else {
                    Toast.makeText(MainActivity.this,
                            getString(R.string.token_error_message),
                            Toast.LENGTH_LONG).show();
                }
            }
        };

        if (checkPlayServices()) {
            // Start IntentService to register this application with GCM.
            Intent intent = new Intent(this, RegistrationIntentService.class);
            startService(intent);
        }


    }
    @Override
    protected void onResume() {
        super.onResume();
        LocalBroadcastManager.getInstance(this).registerReceiver(mRegistrationBroadcastReceiver,
                new IntentFilter(QuickstartPreferences.REGISTRATION_COMPLETE));
    }

    @Override
    protected void onPause() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mRegistrationBroadcastReceiver);
        super.onPause();
    }
    /**
     * Check the device to make sure it has the Google Play Services APK. If
     * it doesn't, display a dialog that allows users to download the APK from
     * the Google Play Store or enable it in the device's system settings.
     */
    private boolean checkPlayServices() {
        int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
                GooglePlayServicesUtil.getErrorDialog(resultCode, this,
                        PLAY_SERVICES_RESOLUTION_REQUEST).show();
            } else {
                Log.i(TAG, "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }

    private View.OnClickListener btnSubmitOnClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            String strUserName = mEdtUserName.getText().toString();
            String strDeviceName = mEdtDeviceName.getText().toString();

            SharedPreferences sharedPreferences =PreferenceManager.getDefaultSharedPreferences(MainActivity.this);

            if(strUserName.equals("") || strDeviceName.equals("")){
                Toast.makeText(MainActivity.this,"請勿留白",Toast.LENGTH_LONG).show();
            }else {
                mStrUserName = mEdtUserName.getText().toString();
                mStrDeviceName = mEdtDeviceName.getText().toString();
                mStrDeviceToken = sharedPreferences.getString(QuickstartPreferences.DEVICE_TOKEN, "");

                sharedPreferences.edit().putString(QuickstartPreferences.USER_NAME,mStrUserName).apply();
                sharedPreferences.edit().putString(QuickstartPreferences.DEVICE_NAME,mStrDeviceName).apply();

                mTxtShowInfo.setText(
                        "GCMService : " + sharedPreferences.getBoolean(QuickstartPreferences.SENT_TOKEN_TO_SERVER, false) + "\n" +
                                "UserName : " + sharedPreferences.getString(QuickstartPreferences.USER_NAME, "") + "\n" +
                                "DeviceName : " + sharedPreferences.getString(QuickstartPreferences.DEVICE_NAME, "") + "\n" +
                                "DeviceToken : " + sharedPreferences.getString(QuickstartPreferences.DEVICE_TOKEN, ""));

                //-------------
                RequestQueue mQueue = Volley.newRequestQueue(MainActivity.this);

                StringRequest stringRequest = new StringRequest(Request.Method.POST, mStrUrl, new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Log.d(TAG,"Response :"+response);
                    }
                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Log.d(TAG,"Response Error :"+error);
                    }
                }){
                    // 携带参数
                    @Override
                    protected HashMap<String, String> getParams()
                            throws AuthFailureError {
                        HashMap<String, String> hashMap = new HashMap<String, String>();
                        hashMap.put("device_token", mStrDeviceToken);
                        hashMap.put("memID", mStrUserName);
                        hashMap.put("memName", mStrDeviceName);

                        return hashMap;
                    }

                };

                mQueue.add(stringRequest);
                //-------------


            }


        }
    };
}
