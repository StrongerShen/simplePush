package com.tomin.patrickchan.simplepush;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.TextView;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

/**
 * Created by patrickchan on 15/7/14.
 */
public class VNewsDetailActivity extends Activity {

    private static final String TAG = "VNewsDetailActivity";

    private TextView mTxtNewsId, mTxtNewsContent, mTxtNewsTitle, mTxtSendTime;

    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news_detail);

        findView();
        showNewsContent();
    }

    private void findView(){
        mTxtNewsId = (TextView)findViewById(R.id.txtNewsId);
        mTxtNewsTitle = (TextView)findViewById(R.id.txtNewsTitle);
        mTxtSendTime = (TextView)findViewById(R.id.txtSendTime);
        mTxtNewsContent = (TextView)findViewById(R.id.txtNewsContent);
    }

    private void showNewsContent(){
        Bundle bundle = VNewsDetailActivity.this.getIntent().getExtras();
        String strNewsId = bundle.getString("newsId");
        String strNewsTitle = bundle.getString("newsTitle");
        String strSendtime = bundle.getString("sendTime");
        mTxtNewsId.setText(strNewsId);
        mTxtNewsTitle.setText(strNewsTitle);
        mTxtSendTime.setText(strSendtime);

        Log.d(TAG,strNewsId+strNewsTitle+strSendtime);

        //---TODO 寫成Class
        //開一個隊列
        RequestQueue mQueue = Volley.newRequestQueue(VNewsDetailActivity.this);
        String mStrUrl = "http://tomin.tw/api/simplePush/Android/responseFullMsg.php";
        //String Request (POST)
        StringRequest stringRequest = new StringRequest(Request.Method.POST, mStrUrl, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {

                JSONObject jsAppServerResponse;
                try{
                    jsAppServerResponse  = new JSONObject(response);

                    String strAppServerRegister = jsAppServerResponse.getString("fullMsg");

                    mTxtNewsContent.setText(strAppServerRegister);


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
                hashMap.put("news_id", mTxtNewsId.getText().toString());


                return hashMap;
            }

        };

        mQueue.add(stringRequest);
        //-------------
    }
}
