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
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.SimpleAdapter;
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

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by patrickchan on 15/7/10.
 */
public class VNewsListActivity extends Activity{

    private static final String TAG = "VNewsListActivity";

    private SimpleAdapter newsArrayAdapter;
    private ArrayList<HashMap<String, String>> news;
    private ListView newsListView;

    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news_list);

        findView();
    }

   @Override
   public void onResume(){
       setNewsList();
       super.onResume();
   }

    private void findView(){

    }

    private void setNewsList(){

        news =new ArrayList<HashMap<String,String>>();

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

                            for (int i = 0; i<jsAryGetContent.length(); i++){

                                HashMap<String, String> item = new HashMap<String, String>();
                                item.put("newsId",jsAryGetContent.getJSONObject(i).getString("newsId"));
                                item.put("preMsg",jsAryGetContent.getJSONObject(i).getString("preMsg"));
                                item.put("sendTime",jsAryGetContent.getJSONObject(i).getString("sendTime"));
                                item.put("haveRead",jsAryGetContent.getJSONObject(i).getString("haveRead"));

                                news.add(item);

//                                mAryNewsId[i] = jsAryGetContent.getJSONObject(i).getString("newsId");
//                                mAryNewsTitle[i] = jsAryGetContent.getJSONObject(i).getString("preMsg");
//                                mArySendTime[i] = jsAryGetContent.getJSONObject(i).getString("sendTime");
//                                mAryHaveRead[i] = jsAryGetContent.getJSONObject(i).getString("haveRead");
                            }

                            newsListView = (ListView)findViewById(R.id.newsListView);
                            newsArrayAdapter = new SimpleAdapter(getApplicationContext(),news,R.layout.news_list_item,new String[]{"newsId","preMsg","sendTime","haveRead"},new int[]{R.id.txtNewsListItem1,R.id.txtNewsListItem2,R.id.txtNewsListItem3,R.id.txtNewsListItem4});
                            newsListView.setAdapter(newsArrayAdapter);

                            newsListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                                @Override
                                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                                    openConversation(news, position);
                                }
                            });

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

    public void openConversation(ArrayList<HashMap<String, String>> news, int position){
        Intent intent = new Intent();
        intent.setClass(VNewsListActivity.this, VNewsDetailActivity.class);
        Bundle bundle = new Bundle();

        bundle.putString("newsId", news.get(position).get("newsId"));
        bundle.putString("newsTitle", news.get(position).get("preMsg"));
        bundle.putString("sendTime", news.get(position).get("sendTime"));
        bundle.putString("haveRead", news.get(position).get("haveRead"));

        intent.putExtras(bundle);
        startActivity(intent);
    }
}
