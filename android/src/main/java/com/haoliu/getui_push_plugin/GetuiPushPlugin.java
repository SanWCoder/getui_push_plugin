package com.haoliu.getui_push_plugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** GetuiPushPlugin */
public class GetuiPushPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "getui_push_plugin");
    channel.setMethodCallHandler(new GetuiPushPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }if (call.method.equals("start")) {
      startSdk(call,result);
    } else {
      result.notImplemented();
    }
  }
  public void startSdk(MethodCall call,Result result){

  }
}
