package com.haoliu.getui_push_plugin;

import android.Manifest;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Message;
import android.support.v4.app.ActivityCompat;
import android.util.Log;

import com.igexin.sdk.GTIntentService;
import com.igexin.sdk.PushConsts;
import com.igexin.sdk.PushManager;
import com.igexin.sdk.message.BindAliasCmdMessage;
import com.igexin.sdk.message.FeedbackCmdMessage;
import com.igexin.sdk.message.GTCmdMessage;
import com.igexin.sdk.message.GTNotificationMessage;
import com.igexin.sdk.message.GTTransmitMessage;
import com.igexin.sdk.message.SetTagCmdMessage;
import com.igexin.sdk.message.UnBindAliasCmdMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * GetuiPushPlugin
 */
public class GetuiPushPlugin implements MethodCallHandler {
  private static final String TAG = "getui_push"; // 打印Tag
  public static String CHANNEL = "getui_push_plugin"; // 通道名
  public static GetuiPushPlugin instance;
  private final Registrar registrar;
  private final MethodChannel channel;
  // 观察透传数据变化.
  private static int cnt;
  // SDK服务是否启动.
  private boolean isServiceRunning = true;
  private static final int REQUEST_PERMISSION = 0;
  private String appkey = "";
  private String appsecret = "";
  private String appid = "";
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
    channel.setMethodCallHandler(new GetuiPushPlugin(registrar, channel));
  }

  private GetuiPushPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
    instance = this;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    Log.d(TAG,call.method);
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    if ("start".equals(call.method)) {
      startSdk(call, result);
    }
//        if ("destroy".equals(call.method)) {
//            destroySdkMethodCall(call, result);
//        }
//    if ([@"resume" isEqualToString:call.method]) {
//      [self resumeSdkMethodCall:call result:result];
//      }if ([@"version" isEqualToString:call.method]) {
//      [self versionSdkMethodCall:call result:result];
//      }if ([@"clientId" isEqualToString:call.method]) {
//      [self clientIdSdkMethodCall:call result:result];
//      }if ([@"status" isEqualToString:call.method]) {
//      [self statusSdkMethodCall:call result:result];
//      }if ([@"setTags" isEqualToString:call.method]) {
//      [self setTagsMethodCall:call result:result];
//      }if ([@"setBadge" isEqualToString:call.method]) {
//      [self setBadgeMethodCall:call result:result];
//      }if ([@"resetBadge" isEqualToString:call.method]) {
//      [self resetBadgeMethodCall:call result:result];
//      }if ([@"setChannelId" isEqualToString:call.method]) {
//      [self setChannelIdMethodCall:call result:result];
//      }if ([@"setPushModeForOff" isEqualToString:call.method]) {
//      [self setPushModeForOffMethodCall:call result:result];
//      }if ([@"bindAlias" isEqualToString:call.method]) {
//      [self bindAliasMethodCall:call result:result];
//      }if ([@"unbindAlias" isEqualToString:call.method]) {
//      [self unbindAliasMethodCall:call result:result];
//      }if ([@"runBackgroundEnable" isEqualToString:call.method]) {
//      [self runBackgroundEnableMethodCall:call result:result];
//      }if ([@"clearAllNotificationBar" isEqualToString:call.method]) {
//      [self clearAllNotificationForNotificationBarMethodCall:call result:result];
//      }if ([@"lbsLocationEnable" isEqualToString:call.method]) {
//      [self lbsLocationEnableMethodCall:call result:result];
//      }
    else {
      result.notImplemented();
    }
  }

  public void startSdk(MethodCall call, Result result) {
    isServiceRunning = true;
    // 配置Manifests
    parseManifests();
    // 初始化
    PackageManager pkgManager = registrar.context().getPackageManager();
    // 访问权限
    boolean sdCardWritePermission =
            pkgManager.checkPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE, registrar.context().getPackageName()) == PackageManager.PERMISSION_GRANTED;

    // 获取imei设备信息权限
    boolean phoneSatePermission =
            pkgManager.checkPermission(Manifest.permission.READ_PHONE_STATE, registrar.context().getPackageName()) == PackageManager.PERMISSION_GRANTED;

    if (Build.VERSION.SDK_INT >= 23 && !sdCardWritePermission || !phoneSatePermission) {
      // 弹出权限框
      requestPermission();
    } else {
      // 初始化载体服务
      PushManager.getInstance().initialize(registrar.context(), com.haoliu.getui_push_plugin.HLPushCarrierService.class);
    }
  }
  private void requestPermission() {
    ActivityCompat.requestPermissions(registrar.activity(), new String[] {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_PHONE_STATE},
            REQUEST_PERMISSION);
  }
  private void parseManifests() {
    String packageName = registrar.context().getPackageName();
    try {
      ApplicationInfo appInfo = registrar.context().getPackageManager().getApplicationInfo(packageName, PackageManager.GET_META_DATA);
      if (appInfo.metaData != null) {
        appid = appInfo.metaData.getString("PUSH_APPID");
        appsecret = appInfo.metaData.getString("PUSH_APPSECRET");
        appkey = appInfo.metaData.getString("PUSH_APPKEY");
        Log.d(TAG,"123333");
        Log.d(TAG, "appkey: " + appkey + "appid: " + appid + "appsecret: " + appsecret);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void destroySdkMethodCall(MethodCall call, Result result) {
//      PushManager.
  }

  /**
   * 接收消息的服务
   * onReceiveMessageData 处理透传消息<br>
   * onReceiveClientId 接收 cid <br>
   * onReceiveOnlineState cid 离线上线通知 <br>
   * onReceiveCommandResult 各种事件处理回执 <br>
   */
  public static class HLReceiveService extends GTIntentService {
    public static String CHANNEL = "com.jzhu.counter/plugin";

    static EventChannel channel;

    static FlutterActivity activity;

    private HLReceiveService(FlutterActivity activity) {
      HLReceiveService.activity = activity;
    }

    private static final String TAG = "Sanw";

    // 观察透传数据变化.
    private static int cnt;

    public HLReceiveService() {

    }

    @Override
    public void onReceiveServicePid(Context context, int pid) {
      Log.d(TAG, "onReceiveServicePid -> " + pid);
    }

    // 收到推送内容
    @Override
    public void onReceiveMessageData(Context context, GTTransmitMessage msg) {
      String appid = msg.getAppid();
      String taskid = msg.getTaskId();
      String messageid = msg.getMessageId();
      byte[] payload = msg.getPayload();
      String pkg = msg.getPkgName();
      String cid = msg.getClientId();

      // 第三方回执调用接口，actionid范围为90000-90999，可根据业务场景执行
      boolean result = PushManager.getInstance().sendFeedbackMessage(context, taskid, messageid, 90001);
      Log.d(TAG, "call sendFeedbackMessage = " + (result ? "success" : "failed"));

      Log.d(TAG, "onReceiveMessageData -> " + "appid = " + appid + "\ntaskid = " + taskid + "\nmessageid = " + messageid + "\npkg = " + pkg
              + "\ncid = " + cid);
      if (payload == null) {
        Log.e(TAG, "receiver payload = null");
      } else {
        String data = new String(payload);
        Log.d(TAG, "receiver payload = " + data);

        // 测试消息为了观察数据变化
        if (data.equals("收到一条透传测试消息")) {
          data = data + "-" + cnt;
          cnt++;
        }
        sendMessage(context, data, 0);
      }
      Log.d(TAG, "----------------------------------------------------------------------------------------------");
    }

    @Override
    public void onReceiveClientId(Context context, String clientid) {
      Log.e(TAG, "onReceiveClientId -> " + "clientid = " + clientid);
//        sendMessage(context,clientid, 1);
    }

    @Override
    public void onReceiveOnlineState(Context context, boolean online) {
      Log.d(TAG, "onReceiveOnlineState -> " + (online ? "online" : "offline"));
    }

    @Override
    public void onReceiveCommandResult(Context context, GTCmdMessage cmdMessage) {
      Log.d(TAG, "onReceiveCommandResult -> " + cmdMessage);

      int action = cmdMessage.getAction();

      if (action == PushConsts.SET_TAG_RESULT) {
        setTagResult((SetTagCmdMessage) cmdMessage);
      } else if (action == PushConsts.BIND_ALIAS_RESULT) {
        bindAliasResult((BindAliasCmdMessage) cmdMessage);
      } else if (action == PushConsts.UNBIND_ALIAS_RESULT) {
        unbindAliasResult((UnBindAliasCmdMessage) cmdMessage);
      } else if ((action == PushConsts.THIRDPART_FEEDBACK)) {
        feedbackResult((FeedbackCmdMessage) cmdMessage);
      }
    }

    @Override
    public void onNotificationMessageArrived(Context context, GTNotificationMessage message) {
      Log.d(TAG, "onNotificationMessageArrived -> " + "appid = " + message.getAppid() + "\ntaskid = " + message.getTaskId() + "\nmessageid = "
              + message.getMessageId() + "\npkg = " + message.getPkgName() + "\ncid = " + message.getClientId() + "\ntitle = "
              + message.getTitle() + "\ncontent = " + message.getContent());
    }

    @Override
    public void onNotificationMessageClicked(Context context, GTNotificationMessage message) {
      Log.d(TAG, "onNotificationMessageClicked -> " + "appid = " + message.getAppid() + "\ntaskid = " + message.getTaskId() + "\nmessageid = "
              + message.getMessageId() + "\npkg = " + message.getPkgName() + "\ncid = " + message.getClientId() + "\ntitle = "
              + message.getTitle() + "\ncontent = " + message.getContent());
    }

    private void setTagResult(SetTagCmdMessage setTagCmdMsg) {
      String sn = setTagCmdMsg.getSn();
      String code = setTagCmdMsg.getCode();
      int text = 0;
//        int text = R.string.add_tag_unknown_exception;
      switch (Integer.valueOf(code)) {
        case PushConsts.SETTAG_SUCCESS:
//                text = R.string.add_tag_success;
          break;

        case PushConsts.SETTAG_ERROR_COUNT:
//                text = R.string.add_tag_error_count;
          break;

        case PushConsts.SETTAG_ERROR_FREQUENCY:
//                text = R.string.add_tag_error_frequency;
          break;

        case PushConsts.SETTAG_ERROR_REPEAT:
//                text = R.string.add_tag_error_repeat;
          break;

        case PushConsts.SETTAG_ERROR_UNBIND:
//                text = R.string.add_tag_error_unbind;
          break;

        case PushConsts.SETTAG_ERROR_EXCEPTION:
//                text = R.string.add_tag_unknown_exception;
          break;

        case PushConsts.SETTAG_ERROR_NULL:
//                text = R.string.add_tag_error_null;
          break;

        case PushConsts.SETTAG_NOTONLINE:
//                text = R.string.add_tag_error_not_online;
          break;

        case PushConsts.SETTAG_IN_BLACKLIST:
//                text = R.string.add_tag_error_black_list;
          break;

        case PushConsts.SETTAG_NUM_EXCEED:
//                text = R.string.add_tag_error_exceed;
          break;

        default:
          break;
      }

      Log.d(TAG, "settag result sn = " + sn + ", code = " + code + ", text = " + getResources().getString(text));
    }

    private void bindAliasResult(BindAliasCmdMessage bindAliasCmdMessage) {
      String sn = bindAliasCmdMessage.getSn();
      String code = bindAliasCmdMessage.getCode();
      int text = 0;
//        int text = R.string.bind_alias_unknown_exception;
      switch (Integer.valueOf(code)) {
        case PushConsts.BIND_ALIAS_SUCCESS:
//                text = R.string.bind_alias_success;
          break;
        case PushConsts.ALIAS_ERROR_FREQUENCY:
//                text = R.string.bind_alias_error_frequency;
          break;
        case PushConsts.ALIAS_OPERATE_PARAM_ERROR:
//                text = R.string.bind_alias_error_param_error;
          break;
        case PushConsts.ALIAS_REQUEST_FILTER:
//                text = R.string.bind_alias_error_request_filter;
          break;
        case PushConsts.ALIAS_OPERATE_ALIAS_FAILED:
//                text = R.string.bind_alias_unknown_exception;
          break;
        case PushConsts.ALIAS_CID_LOST:
//                text = R.string.bind_alias_error_cid_lost;
          break;
        case PushConsts.ALIAS_CONNECT_LOST:
//                text = R.string.bind_alias_error_connect_lost;
          break;
        case PushConsts.ALIAS_INVALID:
//                text = R.string.bind_alias_error_alias_invalid;
          break;
        case PushConsts.ALIAS_SN_INVALID:
//                text = R.string.bind_alias_error_sn_invalid;
          break;
        default:
          break;

      }

      Log.d(TAG, "bindAlias result sn = " + sn + ", code = " + code + ", text = " + getResources().getString(text));

    }

    private void unbindAliasResult(UnBindAliasCmdMessage unBindAliasCmdMessage) {
      String sn = unBindAliasCmdMessage.getSn();
      String code = unBindAliasCmdMessage.getCode();
      int text = 1;
//        int text = R.string.unbind_alias_unknown_exception;
      switch (Integer.valueOf(code)) {
        case PushConsts.UNBIND_ALIAS_SUCCESS:
//                text = R.string.unbind_alias_success;
          break;
        case PushConsts.ALIAS_ERROR_FREQUENCY:
//                text = R.string.unbind_alias_error_frequency;
          break;
        case PushConsts.ALIAS_OPERATE_PARAM_ERROR:
//                text = R.string.unbind_alias_error_param_error;
          break;
        case PushConsts.ALIAS_REQUEST_FILTER:
//                text = R.string.unbind_alias_error_request_filter;
          break;
        case PushConsts.ALIAS_OPERATE_ALIAS_FAILED:
//                text = R.string.unbind_alias_unknown_exception;
          break;
        case PushConsts.ALIAS_CID_LOST:
//                text = R.string.unbind_alias_error_cid_lost;
          break;
        case PushConsts.ALIAS_CONNECT_LOST:
//                text = R.string.unbind_alias_error_connect_lost;
          break;
        case PushConsts.ALIAS_INVALID:
//                text = R.string.unbind_alias_error_alias_invalid;
          break;
        case PushConsts.ALIAS_SN_INVALID:
//                text = R.string.unbind_alias_error_sn_invalid;
          break;
        default:
          break;

      }

      Log.d(TAG, "unbindAlias result sn = " + sn + ", code = " + code + ", text = " + getResources().getString(text));

    }


    private void feedbackResult(FeedbackCmdMessage feedbackCmdMsg) {
      String appid = feedbackCmdMsg.getAppid();
      String taskid = feedbackCmdMsg.getTaskId();
      String actionid = feedbackCmdMsg.getActionId();
      String result = feedbackCmdMsg.getResult();
      long timestamp = feedbackCmdMsg.getTimeStamp();
      String cid = feedbackCmdMsg.getClientId();

      Log.d(TAG, "onReceiveCommandResult -> " + "appid = " + appid + "\ntaskid = " + taskid + "\nactionid = " + actionid + "\nresult = " + result
              + "\ncid = " + cid + "\ntimestamp = " + timestamp);
    }

    private void sendMessage(Context context, String data, int what) {
      Message msg = Message.obtain();
      msg.what = what;
      msg.obj = data;
      Map pushMsg = new HashMap();
      pushMsg.put("content", data);
      pushMsg.put("title", "灏流");

      JSONObject obj = null;
      try {
        obj = new JSONObject(pushMsg);
        Log.d(TAG, "JSON==" + obj);
        HLCustomNotification defaultNotification = new HLCustomNotification(obj, context, cnt++);
        defaultNotification.sendDefaultNotification();
      } catch (JSONException e) {
        e.printStackTrace();
      }

    }

    public static void registerWith(FlutterActivity flutterActivity) {
//        HLReceiveService instance = new HLReceiveService(activity);
//        // 原生调用flutter
//        EventChannel eventChannel = new EventChannel(activit);
//        eventChannel.setStreamHandler(instance);
      activity = flutterActivity;
    }

    public void channe() {
      Log.d(TAG, "channe");
      new EventChannel(activity.getFlutterView(), CHANNEL).setStreamHandler(
              new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object args, final EventChannel.EventSink events) {
                  Log.w(TAG, "adding listener");
                  events.success("adding listener success");
                }

                @Override
                public void onCancel(Object args) {
                  Log.w(TAG, "cancelling listener");
                }
              }
      );
    }
  }
}
