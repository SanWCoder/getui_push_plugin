import 'dart:async';

import 'package:flutter/services.dart';

// 原生事件回调
typedef Future<dynamic> EventHandle(Map<String, dynamic> event);

class GetuiPushPlugin {
  EventHandle _didReceiveRemoteNotification; // 收到推送时的回调
  EventHandle _didRegisterClient; // SDK登入成功返回clientId
  EventHandle _didNotifySdkState; // SDK运行状态通知
  EventHandle _didReceivePayloadData; // SDK通知收到个推推送的透传消息
  EventHandle _didSetPushMode; // SDK设置关闭推送模式回调
  EventHandle _didAliasAction; // SDK绑定、解绑回调
  EventHandle _didQueryTag; // 查询当前绑定tag结果返回
  EventHandle _didOccurError; // SDK遇到错误消息返回error
  static const MethodChannel _channel =
      const MethodChannel('getui_push_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  void start(
    String appId,
    String appKey,
    String appSecret,
  ) {
    _channel.invokeMethod(
        "start", {"appId": appId, "appKey": appKey, "appSecret": appSecret});
  }

  void eventHandle({
      EventHandle didReceiveRemoteNotification, // 收到推送时的回调
      EventHandle didRegisterClient, // SDK登入成功返回clientId
      EventHandle didNotifySdkState, // SDK运行状态通知
      EventHandle didReceivePayloadData, // SDK通知收到个推推送的透传消息
      EventHandle didSetPushMode, // SDK设置关闭推送模式回调
      EventHandle didAliasAction, // SDK绑定、解绑回调
      EventHandle didQueryTag, // 查询当前绑定tag结果返回
      EventHandle didOccurError // SDK遇到错误消息返回error
  }) {
    _didReceiveRemoteNotification = didReceiveRemoteNotification;
    _didRegisterClient = didRegisterClient;
    _didNotifySdkState = didNotifySdkState;
    _didReceivePayloadData = didReceivePayloadData;
    _didSetPushMode = didSetPushMode;
    _didAliasAction = didAliasAction;
    _didQueryTag = didQueryTag;
    _didOccurError = didOccurError;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<Null> _handleMethod(MethodCall call) async {
    print(call.toString());

    switch (call.method) {
      case "onReceiveNotification":
      case "onOpenNotification":
      case "onReceiveMessage":
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }
}
