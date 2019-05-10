package com.haoliu.getui_push_plugin;


import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import org.json.JSONException;
import org.json.JSONObject;

public class HLCustomNotification {

    private Context context;
    private JSONObject jsonObject;
    private String title;
    private String  content;
    private int messageId;// 消息id
    private String type = "推送";
    private int a=0;
    public HLCustomNotification(JSONObject jsonObject, Context context, int cnt){

        this.jsonObject = jsonObject;
        this.context = context;
        this.messageId = cnt;
        System.out.println("obj==="+jsonObject);
    }

    public void sendDefaultNotification() throws JSONException {
        // 此处为了展示不同的消息类型，点击进入不同的消息类型，messageid应为不同
        messageId ++;// 此处id应设置为变量否则会造成后一条会覆盖前一条消息
        if(jsonObject.has("title")){
            title = jsonObject.getString("title");
        }
        if(jsonObject.has("content")){
            content = jsonObject.getString("content");
        }
        System.out.println("content=== "+content + "title===" + title);
        // 定义广播接收器
        // 点击通知栏
        Intent intentClick = new Intent(context, PushReceiver.class);
        intentClick.setAction("notification_clicked");
        intentClick.putExtra(PushReceiver.TYPE, type);
        intentClick.putExtra("obj",jsonObject.toString());
        intentClick.putExtra("a",messageId);
        PendingIntent pendingIntentClick = PendingIntent.getBroadcast(context, messageId, intentClick, PendingIntent.FLAG_UPDATE_CURRENT);//flag应设置为FLAG_UPDATE_CURRENT否则只有一次点击事件

        // 清除
        Intent intentCancel = new Intent(context, PushReceiver.class);
        intentCancel.setAction("notification_cancelled");
        intentCancel.putExtra(PushReceiver.TYPE, type);
        PendingIntent pendingIntentCancel = PendingIntent.getBroadcast(context, messageId, intentCancel, PendingIntent.FLAG_ONE_SHOT);

//        NotificationCompat.Builder builder = new NotificationCompat.Builder(context);
//        builder.setContentTitle(title);//设置标题
//        builder.setContentText(content);//设置内容
////        builder.setSmallIcon(R.mipmap.push);//设置推送的图片
//        builder.setShowWhen(true);//设置显示时间
//        builder.setOngoing(false);//是否可手动消除改通知
//        builder.setAutoCancel(true);
//        // 需要VIBRATE权限
//        builder.setDefaults(Notification.DEFAULT_VIBRATE);
//        builder.setPriority(Notification.PRIORITY_DEFAULT);
//        builder.setContentIntent(pendingIntentClick);
//        builder.setDeleteIntent(pendingIntentCancel);
//        NotificationManager notificationManager = (NotificationManager)context.getSystemService(NOTIFICATION_SERVICE);//通知管理器
//        notificationManager.notify(messageId,builder.build());
    }
}
