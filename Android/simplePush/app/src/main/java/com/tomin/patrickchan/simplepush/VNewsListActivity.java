package com.tomin.patrickchan.simplepush;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
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
public class VNewsListActivity extends AppCompatActivity {

    private static final String TAG = "VNewsListActivity";

    private SimpleAdapter newsArrayAdapter;
    private ArrayList<HashMap<String, String>> news;
    private ListView newsListView;

    private int iItemCount;
    private RequestQueue mQueue;

    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news_list);

        Toolbar toolbar = (Toolbar) findViewById(R.id.news_list_toolbar);
        setSupportActionBar(toolbar);

        findView();
    }

   @Override
   public void onResume(){
       setNewsList();
       super.onResume();
   }
    //覆寫 back 鍵，按下後回到主螢幕
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event){
        if (keyCode == KeyEvent.KEYCODE_BACK)
        {
            // Show home screen when pressing "back" button,
            //  so that this app won't be closed accidentally
            Intent intentHome = new Intent(Intent.ACTION_MAIN);
            intentHome.addCategory(Intent.CATEGORY_HOME);
            intentHome.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intentHome);

            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

    private void findView(){

    }

    private void setNewsList(){

        news =new ArrayList<HashMap<String,String>>();

        //---TODO 寫成Class
        //開一個隊列
        mQueue = Volley.newRequestQueue(VNewsListActivity.this);
        String strUrl = "http://tomin.tw/api/simplePush/Android/getMsgList.php";
        //String Request (POST)
        StringRequest stringRequest = new StringRequest(Request.Method.POST, strUrl,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {

                        JSONObject jsObjAppServerResponse;
                        try{
                            jsObjAppServerResponse  = new JSONObject(response);
                            String strGetContent = jsObjAppServerResponse.getString("content");
                            JSONArray jsAryGetContent = new JSONArray(strGetContent);

                            for (int i = 0; i<jsAryGetContent.length(); i++){

                                String strHaveRead = jsAryGetContent.getJSONObject(i).getString("haveRead");

                                HashMap<String, String> item = new HashMap<String, String>();
                                item.put("newsId",jsAryGetContent.getJSONObject(i).getString("newsId"));
                                item.put("preMsg",jsAryGetContent.getJSONObject(i).getString("preMsg"));
                                item.put("sendTime",jsAryGetContent.getJSONObject(i).getString("sendTime"));

                                if (strHaveRead.equals("1")){
                                    item.put("haveRead","已讀");
                                }else {
                                    item.put("haveRead","未讀");
                                }

                                news.add(item);

                            }

                            newsListView = (ListView)findViewById(R.id.newsListView);
                            newsArrayAdapter = new SimpleAdapter(
                                    getApplicationContext(),
                                    news,R.layout.news_list_item,
                                    new String[]{"newsId","preMsg","sendTime","haveRead"},
                                    new int[]{
                                            R.id.txtNewsListItem1,
                                            R.id.txtNewsListItem2,
                                            R.id.txtNewsListItem3,
                                            R.id.txtNewsListItem4}){
                                @Override
                                public View getView(int position, View convertView, ViewGroup parent) {

                                    View view = super.getView(position, convertView, parent);
                                    TextView txtHeavRead = (TextView) view.findViewById(R.id.txtNewsListItem4);

                                    String strHeavRead = news.get(position).get("haveRead");

                                    Log.d(TAG,strHeavRead);

                                    if (strHeavRead.equals("未讀")){
                                        txtHeavRead.setBackgroundResource(R.drawable.unreadbox);
                                        txtHeavRead.setTextColor(getResources().getColor(R.color.off_white));
                                    }
                                    return view;
                                }
                            };

                            newsListView.setAdapter(newsArrayAdapter);

                            View newsListViewChildAt = newsListView.getChildAt(0);

                            newsListView.getAdapter(

                            );

                            newsListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                                @Override
                                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                                    openConversation(news, position);
                                }
                            });

                            newsListView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
                                @Override
                                public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
                                    iItemCount = position;
                                    AlertDialog.Builder alert = new AlertDialog.Builder(VNewsListActivity.this);
                                    alert.setTitle("刪除");
                                    alert.setPositiveButton("YES", new DialogInterface.OnClickListener() {

                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {

                                            String strUrl = "http://tomin.tw/api/simplePush/Android/delMsg.php";
                                            //String Request (POST)
                                            StringRequest stringRequest = new StringRequest(Request.Method.POST, strUrl,
                                                    new Response.Listener<String>() {
                                                        @Override
                                                        public void onResponse(String response) {

                                                            JSONObject jsObjAppServerResponse;
                                                            try{
                                                                jsObjAppServerResponse  = new JSONObject(response);
                                                                String strSuccessful = jsObjAppServerResponse.getString("ret_code");

                                                                if (strSuccessful.equals("YES")){
                                                                    news.remove(iItemCount);
                                                                    newsArrayAdapter.notifyDataSetChanged();
                                                                }else{
                                                                    Toast.makeText(VNewsListActivity.this, "刪除失敗",Toast.LENGTH_LONG).show();
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

                                                    String strNewsId = news.get(iItemCount).get("newsId");


                                                    HashMap<String, String> hashMap = new HashMap<String, String>();

                                                    hashMap.put("news_id", strNewsId);

                                                    return hashMap;
                                                }

                                            };

                                            mQueue.add(stringRequest);
                                            //-------------



                                        }
                                    });
                                    alert.setNegativeButton("NO", null);
                                    alert.show();
                                    return true;
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
