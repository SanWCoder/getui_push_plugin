package com.haoliu.getui_push_plugin;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;

public class HLChannelHandle {
    /**
     * 通道名称，必须与flutter注册的一致
     */
    static final String channels_native_to_flutter = "com.bhm.flutter.flutternb.plugins/native_to_flutter";

    /**原生调用flutter方法的回调
     * @param activity activity
     * @param o o
     * @param eventSink eventSink
     */
    static void onListen(FlutterActivity activity, Object o, EventChannel.EventSink eventSink){
        // 在此调用
        eventSink.success("onConnected");

    }

    /**原生调用flutter方法的回调
     * @param activity activity
     * @param o o
     */
    static void onCancel(FlutterActivity activity, Object o) {

    }
}
