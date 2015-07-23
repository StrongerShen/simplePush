package com.tomin.simplepush;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Build;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;


public class VCLoginActivity extends AppCompatActivity {

    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;
    private static final String TAG = "MainActivity";

    String mStrUrl = "http://tomin.tw/api/simplePush/Android/DeviceRegister.php";

    private BroadcastReceiver mRegistrationBroadcastReceiver;
    private ProgressBar mRegistrationProgressBar;
    private EditText mEdtUserName, mEdtPassword, mEdtVerifyPassword;
    private Button mBtnSubmit;
    private TextView mTxtShowInfo;

    String mStrUserName, mStrPassword, mStrPasswordMD5, mStrVerifyPassword, mStrDeviceName, mStrDeviceToken;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vclogin);

        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(VCLoginActivity.this);

        Toolbar toolbar = (Toolbar) findViewById(R.id.news_detail_toolbar);
        setSupportActionBar(toolbar);

        toolbar.setTitleTextColor(getResources().getColor(R.color.off_white));

        mTxtShowInfo = (TextView)findViewById(R.id.txtShowInfo);
        mRegistrationProgressBar = (ProgressBar) findViewById(R.id.registrationProgressBar);

        mEdtUserName = (EditText)findViewById(R.id.edtUserName);
        mEdtPassword = (EditText)findViewById(R.id.edtPassword);
        mEdtVerifyPassword = (EditText)findViewById(R.id.edtVerifyPassword);
        mBtnSubmit = (Button)findViewById(R.id.btnSubmit);

        mBtnSubmit.setOnClickListener(btnSubmitOnClick);

        mRegistrationBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                mRegistrationProgressBar.setVisibility(ProgressBar.GONE);
                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(VCLoginActivity.this);

                boolean sentToken = sharedPreferences
                        .getBoolean(QuickstartPreferences.SENT_TOKEN_TO_SERVER, false);
                if (sentToken) {
                    mBtnSubmit.setVisibility(View.VISIBLE);
                } else {
                    Toast.makeText(VCLoginActivity.this,
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

        boolean bAppServerResgister = sharedPreferences.getBoolean(QuickstartPreferences.APP_SERVER_REGISTER, false);

        if (bAppServerResgister){
            Intent intent = new Intent();
            intent.setClass(VCLoginActivity.this,VCNewsListActivity.class);
            startActivity(intent);
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
            SharedPreferences sharedPreferences =PreferenceManager.getDefaultSharedPreferences(VCLoginActivity.this);

            String strManufacturer = Build.MANUFACTURER;
            String strModel = Build.MODEL;

            mStrUserName = mEdtUserName.getText().toString();
            mStrPassword = mEdtPassword.getText().toString();
            mStrPasswordMD5 = md5(mStrPassword);
            mStrVerifyPassword = mEdtVerifyPassword.getText().toString();
            mStrDeviceName = strManufacturer + " " + strModel;
            mStrDeviceToken = sharedPreferences.getString(QuickstartPreferences.DEVICE_TOKEN, "");



            if(mStrUserName.equals("") || mStrPassword.equals("") || mStrVerifyPassword.equals("")){
                Toast.makeText(VCLoginActivity.this,"請勿留白",Toast.LENGTH_LONG).show();
            }
            else if(!mStrPassword.equals(mStrVerifyPassword)){
                Toast.makeText(VCLoginActivity.this,"密碼驗證錯誤",Toast.LENGTH_LONG).show();
                mEdtVerifyPassword.setText("");
            }
            else {
                sharedPreferences.edit().putString(QuickstartPreferences.USER_NAME,mStrUserName).apply();
                sharedPreferences.edit().putString(QuickstartPreferences.PASSWORD,mStrPasswordMD5).apply();
                sharedPreferences.edit().putString(QuickstartPreferences.DEVICE_NAME,mStrDeviceName).apply();

                mTxtShowInfo.setText(
                        "GCMService : " + sharedPreferences.getBoolean(QuickstartPreferences.SENT_TOKEN_TO_SERVER, false) + "\n" +
                                "UserName : " + sharedPreferences.getString(QuickstartPreferences.USER_NAME, "") + "\n" +
                                "Password : " + sharedPreferences.getString(QuickstartPreferences.PASSWORD, "") + "\n" +
                                "DeviceName : " + sharedPreferences.getString(QuickstartPreferences.DEVICE_NAME, "") + "\n" +
                                "DeviceToken : " + sharedPreferences.getString(QuickstartPreferences.DEVICE_TOKEN, ""));

                //---TODO 寫成Class
                //開一個隊列
                RequestQueue mQueue = Volley.newRequestQueue(VCLoginActivity.this);
                //String Request (POST)
                StringRequest stringRequest = new StringRequest(Request.Method.POST, mStrUrl, new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {

                        JSONObject jsAppServerResponse;
                        try{
                            jsAppServerResponse  = new JSONObject(response);

                            String strAppServerRegister = jsAppServerResponse.getString("ret_code");

                            SharedPreferences sharedPreferences =PreferenceManager.getDefaultSharedPreferences(VCLoginActivity.this);
                            if (strAppServerRegister.equals("YES")){
                                sharedPreferences.edit().putBoolean(QuickstartPreferences.APP_SERVER_REGISTER, true).apply();
                                Intent intent = new Intent();
                                intent.setClass(VCLoginActivity.this,VCNewsListActivity.class);
                                startActivity(intent);
                            }else {
                                sharedPreferences.edit().putBoolean(QuickstartPreferences.APP_SERVER_REGISTER, false).apply();
                            }

                        }catch (JSONException e){
                            e.printStackTrace();
                        }

                        Log.d(TAG,"Response :"+response);
                    }
                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Log.d(TAG,"Response Error :"+error);
                    }
                }){
                    // 帶參數
                    @Override
                    protected HashMap<String, String> getParams()
                            throws AuthFailureError {
                        HashMap<String, String> hashMap = new HashMap<String, String>();
                        hashMap.put("device_token", mStrDeviceToken);
                        hashMap.put("memID", mStrUserName);
                        hashMap.put("memPwd", mStrPasswordMD5);
                        hashMap.put("memName", mStrDeviceName);
                        hashMap.put("device_type", "1");

                        return hashMap;
                    }

                };

                mQueue.add(stringRequest);
                //-------------

            }
        }
    };
    //String MD5加密
    public static final String md5(final String toEncrypt) {
        try {
            final MessageDigest digest = MessageDigest.getInstance("md5");
            digest.update(toEncrypt.getBytes());
            final byte[] bytes = digest.digest();
            final StringBuilder sb = new StringBuilder();
            for (int i = 0; i < bytes.length; i++) {
                sb.append(String.format("%02X", bytes[i]));
            }
            return sb.toString().toLowerCase();
        } catch (Exception exc) {
            return ""; // Impossibru!
        }
    }
}
