import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:getui_push_plugin/getui_push_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final gettui = new GetuiPushPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetuiPushPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    gettui.start("iMahVVxurw6BNr7XSn9EF2", "yIPfqwq6OMAPp6dkqgLpG5",
        "G0aBqAD6t79JfzTB6Z5lo5");
    gettui.eventHandle(
      // 收到推送时的回调
      didReceiveRemoteNotification: (Map<String, dynamic> event) async {
        print("收到推送时的回调:$event");
      },
      // SDK登入成功返回clientId
      didRegisterClient: (Map<String, dynamic> event) async {
        print("SDK登入成功返回clientId:$event");
      },
      // SDK运行状态通知
      didNotifySdkState: (Map<String, dynamic> event) async {
        print("SDK运行状态通知:$event");
      },
      // SDK通知收到个推推送的透传消息
      didReceivePayloadData: (Map<String, dynamic> event) async {
        print("SDK通知收到个推推送的透传消息:$event");
      },
      // SDK设置关闭推送模式回调
      didSetPushMode: (Map<String, dynamic> event) async {
        print("SDK设置关闭推送模式回调:$event");
      },
      // SDK绑定、解绑回调
      didAliasAction: (Map<String, dynamic> event) async {
        print("SDK绑定、解绑回调:$event");
      },
      // 查询当前绑定tag结果返回
      didQueryTag: (Map<String, dynamic> event) async {
        print("查询当前绑定tag结果返回:$event");
      },
      // SDK遇到错误消息返回error
      didOccurError: (Map<String, dynamic> event) async {
        print("SDK遇到错误消息返回error:$event");
      },
    );
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
