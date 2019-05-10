package com.haoliu.getui_push_plugin;

import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import static android.content.Context.NOTIFICATION_SERVICE;

public class PushReceiver extends BroadcastReceiver {
    public static final String TYPE = "type";
    private String obj;
    @Override
    public void onReceive(Context context, Intent intent) {
        // TODO: This method is called when the BroadcastReceiver is receiving
        String action = intent.getAction();
        System.out.println(" 点击了");

        // 点击
        if (action.equals("notification_clicked")) {
            // 处理点击事件
            System.out.println(" 点击了"+intent.getStringExtra("obj"));
            obj = intent.getStringExtra("obj");//获取到了数据后续就做我们自己需要做的事情
            int a = intent.getIntExtra("a",-1);
            if(a != -1) {
                NotificationManager notifiMgr = (NotificationManager)context.getSystemService(NOTIFICATION_SERVICE);
                System.out.println("点击了"+a);
                notifiMgr.cancel(a);

            }
            if(obj!=null){
                // 将数据回传
            }

        }

        // 删除，取消
        if (action.equals("notification_cancelled")) {
            // 处理滑动清除和点击删除事件
            System.out.println("删除了");
        }
    }
}
