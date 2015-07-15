package com.tomin.patrickchan.simplepush;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

/**
 * Created by patrickchan on 15/7/10.
 */
public class VNewsListActivity extends Activity{

    private static final String TAG = "VNewsListActivity";

    private TableLayout layoutNewsList;

    private String[] mAryNewsTitle, mAryNewsId, mArySendTime, mAryHaveRead;

    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news_list);

        findView();

        //---TODO 寫成Class
        //開一個隊列
        RequestQueue mQueue = Volley.newRequestQueue(VNewsListActivity.this);
        String mStrUrl = "http://tomin.tw/api/simplePush/Android/getMsgList.php";
        //String Request (POST)
        StringRequest stringRequest = new StringRequest(Request.Method.POST, mStrUrl,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {

                        JSONObject jsObjAppServerResponse;
                        try{
                            jsObjAppServerResponse  = new JSONObject(response);
                            String strGetContent = jsObjAppServerResponse.getString("content");
                            JSONArray jsAryGetContent = new JSONArray(strGetContent);

                            mAryNewsId = new String[jsAryGetContent.length()];
                            mAryNewsTitle = new String[jsAryGetContent.length()];
                            mArySendTime = new String[jsAryGetContent.length()];
                            mAryHaveRead = new String[jsAryGetContent.length()];

                            layoutNewsList.setStretchAllColumns(true);
                            TableLayout.LayoutParams rowLayout = new TableLayout.LayoutParams(TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT);
                            TableRow.LayoutParams viewLayout = new TableRow.LayoutParams(TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT);

                            for (int i = 0; i<jsAryGetContent.length(); i++){


                                mAryNewsId[i] = jsAryGetContent.getJSONObject(i).getString("newsId");
                                mAryNewsTitle[i] = jsAryGetContent.getJSONObject(i).getString("preMsg");
                                mArySendTime[i] = jsAryGetContent.getJSONObject(i).getString("sendTime");
                                mAryHaveRead[i] = jsAryGetContent.getJSONObject(i).getString("haveRead");

                                final TableRow tr = new TableRow(VNewsListActivity.this);
                                tr.setLayoutParams(rowLayout);
                                tr.setGravity(Gravity.CENTER_HORIZONTAL);

                                TextView txtNewsId = new TextView(VNewsListActivity.this);
                                txtNewsId.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20);
                                txtNewsId.setText(mAryNewsId[i]);
                                txtNewsId.setLayoutParams(viewLayout);

                                TextView txtPreMsg = new TextView(VNewsListActivity.this);
                                txtPreMsg.setTextSize(TypedValue.COMPLEX_UNIT_SP,20);
                                txtPreMsg.setText(mAryNewsTitle[i]);
                                txtPreMsg.setLayoutParams(viewLayout);


                                TextView txtHaveRead = new TextView(VNewsListActivity.this);
                                txtHaveRead.setTextSize(TypedValue.COMPLEX_UNIT_SP,20);
                                txtHaveRead.setText(mAryHaveRead[i]);
                                txtHaveRead.setLayoutParams(viewLayout);

                                tr.addView(txtNewsId);
                                tr.addView(txtPreMsg);
                                tr.addView(txtHaveRead);

                                tr.setTag(i);

                                tr.setOnClickListener(new View.OnClickListener() {

                                    @Override
                                    public void onClick(View v) {

                                        int iTag = (int)v.getTag();

                                        Intent intent = new Intent();
                                        intent.setClass(VNewsListActivity.this, VNewsDetailActivity.class);
                                        Bundle bundle = new Bundle();
                                        bundle.putString("newsId", mAryNewsId[iTag]);
                                        bundle.putString("newsTitle", mAryNewsTitle[iTag]);
                                        bundle.putString("sendTime", mArySendTime[iTag]);
                                        intent.putExtras(bundle);
                                        startActivity(intent);
                                    }
                                });

                                layoutNewsList.addView(tr);

                            }

                            Log.d(TAG,"Response : "+response);

                        }catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Log.d(TAG,"Response Error :"+error);
                }
        }){
            // 帶參數
            @Override
            protected HashMap<String, String> getParams()
                    throws AuthFailureError {

                SharedPreferences sharedPreferences =PreferenceManager.getDefaultSharedPreferences(VNewsListActivity.this);
                String strUserName = sharedPreferences.getString(QuickstartPreferences.USER_NAME, "");

                HashMap<String, String> hashMap = new HashMap<String, String>();

                hashMap.put("member_id", strUserName);

                return hashMap;
            }

        };

        mQueue.add(stringRequest);
        //-------------

    }

    private void findView(){
        layoutNewsList = (TableLayout)findViewById(R.id.layout_news_list);
    }
}
