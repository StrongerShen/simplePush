package com.tomin.simplepush;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.github.arturogutierrez.Badges;
import com.github.arturogutierrez.BadgesNotSupportedException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by patrickchan on 15/7/21.
 */
public class VCNewsListActivity extends AppCompatActivity {

    private static final String TAG = "VNewsListActivity";

    private SimpleAdapter newsArrayAdapter;
    private ArrayList<HashMap<String, String>> news;
    private ListView newsListView;

    private int iItemCount;
    private int iBadgeNumber;
    private RequestQueue mRequestQueue;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vcnewslist);

        Toolbar toolbar = (Toolbar) findViewById(R.id.news_list_toolbar);
        setSupportActionBar(toolbar);

        toolbar.setTitleTextColor(getResources().getColor(R.color.off_white));
    }

    @Override
    public void onResume(){
        setNewsList();
        super.onResume();
    }
    @Override
    protected void onStop(){
        super.onStop();
        if (mRequestQueue != null) {
            mRequestQueue.cancelAll(TAG);
            Log.d(TAG,"Cancel a Request");
        }
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
    //更新BadgeNumber
    private void updateBadge(int count) {
        try {
            Badges.setBadge(this, count);
        } catch (BadgesNotSupportedException badgesNotSupportedException) {
            Log.d(TAG, badgesNotSupportedException.getMessage());
        }
    }
    //更新新聞列表
    private void setNewsList(){

        news =new ArrayList<HashMap<String,String>>();
        //取得新聞列表
        //---TODO 寫成Class
        //開一個隊列
        mRequestQueue = Volley.newRequestQueue(VCNewsListActivity.this);
        String strUrl = "http://tomin.tw/api/simplePush/Android/getMsgList.php";
        //String Request (POST)
        StringRequest stringRequest = new StringRequest(Request.Method.POST, strUrl,
                new Response.Listener<String>() {

                    //Response
                    @Override
                    public void onResponse(String response) {

                        JSONObject jsObjAppServerResponse;
                        try{
                            jsObjAppServerResponse  = new JSONObject(response);
                            iBadgeNumber = Integer.parseInt(jsObjAppServerResponse.getString("msgNumNread"));
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

                            updateBadge(iBadgeNumber);

                            //[begin] - newsListView -> newsArrayAdapter
                            //指定給 newsListView 的轉接器 newsArrayAdapter ，連結 R.layout.news_list_item

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
                                //取得 newsListView 的 subview ，更改 subview 的 未讀 textView 背景顏色
                                @Override
                                public View getView(int position, View convertView, ViewGroup parent) {

                                    View view = super.getView(position, convertView, parent);
                                    TextView txtHaveRead = (TextView) view.findViewById(R.id.txtNewsListItem4);

                                    String strHaveRead = news.get(position).get("haveRead");

                                    if (strHaveRead.equals("未讀")){
                                        txtHaveRead.setBackgroundResource(R.drawable.unreadbox);
                                        txtHaveRead.setTextColor(getResources().getColor(R.color.off_white));
                                    }
                                    return view;
                                }
                            };

                            newsListView.setAdapter(newsArrayAdapter);
                            //[end] - newsListView -> newsArrayAdapter

                            //click 監聽事件，點擊 newsListView Item 進 VCNewsDetailActivity
                            newsListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                                @Override
                                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                                    openConversation(news, position);
                                }
                            });
                            //長按監聽事件，ListView Item 長按 跳出 AlertDialog 顯示是否刪除
                            newsListView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
                                @Override
                                public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {

                                    iItemCount = position;

                                    AlertDialog.Builder alert = new AlertDialog.Builder(VCNewsListActivity.this);
                                    alert.setTitle("刪除");
                                    //AlertDialog YES Button 點擊事件
                                    alert.setPositiveButton("YES", new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {

                                            //新增一個刪除請求，請求成功刪除資料庫一筆資料，失敗彈出Toas提示刪除失敗
                                            String strUrl = "http://tomin.tw/api/simplePush/Android/delMsg.php";
                                            //String Request (POST)
                                            StringRequest stringRequest = new StringRequest(Request.Method.POST, strUrl,
                                                    new Response.Listener<String>() {

                                                        //取得回應
                                                        @Override
                                                        public void onResponse(String response) {

                                                            JSONObject jsObjAppServerResponse;
                                                            try{
                                                                jsObjAppServerResponse  = new JSONObject(response);

                                                                //取得JSON物的ret_code（YES, NO）值
                                                                String strSuccessful = jsObjAppServerResponse.getString("ret_code");

                                                                if (strSuccessful.equals("YES")){
                                                                    //刪除news內一筆資料
                                                                    news.remove(iItemCount);
                                                                    //ListView reloadData
                                                                    newsArrayAdapter.notifyDataSetChanged();
                                                                }else{
                                                                    Toast.makeText(VCNewsListActivity.this, "刪除失敗", Toast.LENGTH_LONG).show();
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

                                            mRequestQueue.add(stringRequest);
                                            //-------------
                                        }
                                    });
                                    //AlertDialog NO Button 點擊取消
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

                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(VCNewsListActivity.this);
                String strUserName = sharedPreferences.getString(QuickstartPreferences.USER_NAME, "");

                HashMap<String, String> hashMap = new HashMap<String, String>();

                hashMap.put("member_id", strUserName);

                return hashMap;
            }

        };
        stringRequest.setTag(TAG);
        mRequestQueue.add(stringRequest);
        //-------------
    }

    public void openConversation(ArrayList<HashMap<String, String>> news, int position){
        Intent intent = new Intent();
        intent.setClass(VCNewsListActivity.this, VCNewsDetailActivity.class);
        Bundle bundle = new Bundle();

        bundle.putString("newsId", news.get(position).get("newsId"));
        bundle.putInt("badgeNumber", iBadgeNumber);

        intent.putExtras(bundle);
        startActivity(intent);
    }

}
