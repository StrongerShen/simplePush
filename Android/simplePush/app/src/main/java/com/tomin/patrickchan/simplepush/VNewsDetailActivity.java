package com.tomin.patrickchan.simplepush;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.NavUtils;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.ListView;
import android.widget.SimpleAdapter;
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

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by patrickchan on 15/7/14.
 */
public class VNewsDetailActivity extends AppCompatActivity {

    private static final String TAG = "VNewsDetailActivity";

    private String strNewsId,strNewsTitle,strSendtime;

    private SimpleAdapter newsArrayAdapter;
    private ArrayList<HashMap<String, String>> news;
    private ListView newsDetailView;



    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news_detail);

        Toolbar toolbar = (Toolbar) findViewById(R.id.news_detail_toolbar);
        setSupportActionBar(toolbar);

        toolbar.setNavigationIcon(R.drawable.abc_ic_ab_back_mtrl_am_alpha);
        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
               onBackPressed();
            }
        });

        findView();
        showNewsContent();
    }

    private void findView(){

    }

    private void showNewsContent(){
        Bundle bundle = VNewsDetailActivity.this.getIntent().getExtras();
        strNewsId = bundle.getString("newsId");
        strNewsTitle = bundle.getString("newsTitle");
        strSendtime = bundle.getString("sendTime");

        news =new ArrayList<HashMap<String,String>>();

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

                    HashMap<String, String> item = new HashMap<String, String>();

                    item.put("newsTitle",strNewsTitle);
                    item.put("sendTime",strSendtime);
                    item.put("fullMsg", strAppServerRegister);

                    news.add(item);
                    newsDetailView = (ListView)findViewById(R.id.newsDetailView);
                    newsArrayAdapter = new SimpleAdapter(
                            getApplicationContext(),
                            news,R.layout.news_detail_item,
                            new String[]{"newsTitle","sendTime","fullMsg"},
                            new int[]{
                                    R.id.txtNewsDetailItem1,
                                    R.id.txtNewsDetailItem2,
                                    R.id.txtNewsDetailItem3,});

                    newsDetailView.setAdapter(newsArrayAdapter);


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
                hashMap.put("news_id", strNewsId);


                return hashMap;
            }

        };

        mQueue.add(stringRequest);
        //-------------
    }
}
