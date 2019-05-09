#import "GetuiPushPlugin.h"
#import <GTSDK/GeTuiSdk.h>
// iOS10 及以上需导入 UserNotifications.framework
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
@interface GetuiPushPlugin ()<GeTuiSdkDelegate,UNUserNotificationCenterDelegate>

@end

@implementation GetuiPushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"getui_push_plugin"
            binaryMessenger:[registrar messenger]];
  GetuiPushPlugin* instance = [[GetuiPushPlugin alloc] init];
  instance.channel = channel;
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }if ([@"start" isEqualToString:call.method]) {
      [self startSdkMethodCall:call result:result];
  }if ([@"destroy" isEqualToString:call.method]) {
      [self destroySdkMethodCall:call result:result];
  }if ([@"resume" isEqualToString:call.method]) {
      [self resumeSdkMethodCall:call result:result];
  }if ([@"version" isEqualToString:call.method]) {
      [self versionSdkMethodCall:call result:result];
  }if ([@"clientId" isEqualToString:call.method]) {
      [self clientIdSdkMethodCall:call result:result];
  }if ([@"status" isEqualToString:call.method]) {
      [self statusSdkMethodCall:call result:result];
  }if ([@"setTags" isEqualToString:call.method]) {
      [self setTagsMethodCall:call result:result];
  }if ([@"setBadge" isEqualToString:call.method]) {
      [self setBadgeMethodCall:call result:result];
  }if ([@"resetBadge" isEqualToString:call.method]) {
      [self resetBadgeMethodCall:call result:result];
  }if ([@"setChannelId" isEqualToString:call.method]) {
      [self setChannelIdMethodCall:call result:result];
  }if ([@"setPushModeForOff" isEqualToString:call.method]) {
      [self setPushModeForOffMethodCall:call result:result];
  }if ([@"bindAlias" isEqualToString:call.method]) {
      [self bindAliasMethodCall:call result:result];
  }if ([@"unbindAlias" isEqualToString:call.method]) {
      [self unbindAliasMethodCall:call result:result];
  }if ([@"runBackgroundEnable" isEqualToString:call.method]) {
      [self runBackgroundEnableMethodCall:call result:result];
  }if ([@"clearAllNotificationBar" isEqualToString:call.method]) {
      [self clearAllNotificationForNotificationBarMethodCall:call result:result];
  }if ([@"lbsLocationEnable" isEqualToString:call.method]) {
      [self lbsLocationEnableMethodCall:call result:result];
  }else {
     result(FlutterMethodNotImplemented);
  }
}

/**
 *  启动个推SDK
 *
 *  @param appid     设置app的个推appId，此appId从个推网站获取
 *  @param appKey    设置app的个推appKey，此appKey从个推网站获取
 *  @param appSecret 设置app的个推appSecret，此appSecret从个推网站获取
 *  @param delegate  回调代理delegate
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)startSdkMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSDictionary *arguments = call.arguments;
    [GeTuiSdk startSdkWithAppId:arguments[@"appId"] appKey:arguments[@"appKey"] appSecret:arguments[@"appSecret"] delegate:self];
    // 注册Sdk
    [self registerRemoteNotification];
}
/** 注册 APNs */
- (void)registerRemoteNotification {
    /*
     警告：Xcode8 需要手动开启"TARGETS -> Capabilities -> Push Notifications"
     */
    
    /*
     警告：该方法需要开发者自定义，以下代码根据 APP 支持的 iOS 系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的 iOS 系统都能获取到 DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
}
/**
 销毁SDK，并且释放资源
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)destroySdkMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    [GeTuiSdk destroy];
}
/**
 恢复SDK运行,IOS7 以后支持Background Fetch方式，后台定期更新数据,该接口需要在Fetch起来后被调用，保证SDK 数据获取。
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)resumeSdkMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    [GeTuiSdk resume];
}
/**
 *  获取SDK版本号
 *
 *  当前GeTuiSdk版本, 当前文件头部(顶部)可见
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)versionSdkMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    result([GeTuiSdk version]);
}

/**
 *  获取SDK的Cid
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)clientIdSdkMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    result([GeTuiSdk clientId]);
}

/**
 *  获取SDK运行状态
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)statusSdkMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    result(@([GeTuiSdk status]));
}
#pragma mark -

/**
 *  给用户打标签 , 后台可以根据标签进行推送
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)setTagsMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    
    result(@([GeTuiSdk setTags:call.arguments]));
}
/**
 *  同步角标值到个推服务器
 *  该方法只是同步角标值到个推服务器，本地仍须调用setApplicationIconBadgeNumber函数
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)setBadgeMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSUInteger badge = (NSUInteger)call.arguments;
    [GeTuiSdk setBadge:badge];
}


/**
 *  复位角标，等同于"setBadge:0"
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)resetBadgeMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    [GeTuiSdk resetBadge];
}

/**
 *  设置渠道
 *  备注：SDK可以未启动就调用该方法
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)setChannelIdMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    [GeTuiSdk setChannelId:call.arguments];
}

/**
 *  设置关闭推送模式（默认值：NO）
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)setPushModeForOffMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    [GeTuiSdk setPushModeForOff:call.arguments];
}

/**
 *  绑定别名功能:后台可以根据别名进行推送
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)bindAliasMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSDictionary *arguments = call.arguments;
    [GeTuiSdk bindAlias:arguments[@"alias"] andSequenceNum:arguments[@"aSn"]];
}

/**
 *  取消绑定别名功能
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)unbindAliasMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSDictionary *arguments = call.arguments;
    [GeTuiSdk unbindAlias:arguments[@"alias"] andSequenceNum:arguments[@"aSn"] andIsSelf:arguments[@"isSelf"]];
}
#pragma mark -




#pragma mark -

/**
 *  是否允许SDK 后台运行（默认值：NO）
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)runBackgroundEnableMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    [GeTuiSdk runBackgroundEnable:call.arguments];
}
/**
 *  地理围栏功能，设置地理围栏是否运行
 *  备注：SDK可以未启动就调用该方法
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)lbsLocationEnableMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSDictionary *arguments = call.arguments;

    [GeTuiSdk lbsLocationEnable:arguments[@"isEnable"] andUserVerify:arguments[@"isVerify"]];
}
/**
 *  清空下拉通知栏全部通知,并将角标置“0”，不显示角标
 @param call <#call description#>
 @param result <#result description#>
 */
- (void)clearAllNotificationForNotificationBarMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    [GeTuiSdk clearAllNotificationForNotificationBar];
}
#pragma mark - GeTuiSdkDelegete
/**
 *  SDK登入成功返回clientId
 *
 *  @param clientId 标识用户的clientId
 *  说明:启动GeTuiSdk后，SDK会自动向个推服务器注册SDK，当成功注册时，SDK通知应用注册成功。
 *  注意: 注册成功仅表示推送通道建立，如果appid/appkey/appSecret等验证不通过，依然无法接收到推送消息，请确保验证信息正确。
 */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId{
    [_channel invokeMethod:@"didRegisterClient" arguments:clientId];
}

/**
 *  SDK运行状态通知
 *
 *  @param aStatus 返回SDK运行状态
 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus{
    
    [_channel invokeMethod:@"didNotifySdkState" arguments:@(aStatus)];
}

/**
 *  SDK通知收到个推推送的透传消息
 *  @param payloadData 推送消息内容
 *  @param taskId      推送消息的任务id
 *  @param msgId       推送消息的messageid
 *  @param offLine     是否是离线消息，YES.是离线消息
 *  @param appId       应用的appId
 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId{
    [_channel invokeMethod:@"didReceivePayloadData" arguments:@{@"payloadData":payloadData,@"taskId":taskId,@"msgId":msgId,@"offLine":@(offLine),@"appId":appId}];
}
/**
 *  SDK通知发送上行消息结果，收到sendMessage消息回调
 *
 *  @param messageId “sendMessage:error:”返回的id
 *  @param result    成功返回1, 失败返回0
 *  说明: 当调用sendMessage:error:接口时，消息推送到个推服务器，服务器通过该接口通知sdk到达结果，result为 1 说明消息发送成功
 *  注意: 需第三方服务器接入个推,SendMessage 到达第三方服务器后返回 1
 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result{
    [_channel invokeMethod:@"didReceivePayloadData" arguments:@{@"messageId":messageId,@"result":@(result)}];
}

/**
 *  SDK设置关闭推送模式回调
 *
 *  @param isModeOff 关闭模式，YES.服务器关闭推送功能 NO.服务器开启推送功能
 *  @param error     错误回调，返回设置时的错误信息
 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error{
    [_channel invokeMethod:@"didSetPushMode" arguments:@{@"isModeOff":@(isModeOff),@"error":error}];
}

/**
 *  SDK绑定、解绑回调
 *
 *  @param action       回调动作类型 kGtResponseBindType 或 kGtResponseUnBindType
 *  @param isSuccess    成功返回 YES, 失败返回 NO
 *  @param aSn          返回请求的序列码
 *  @param aError       成功返回nil, 错误返回相应error信息
 */
- (void)GeTuiSdkDidAliasAction:(NSString *)action result:(BOOL)isSuccess sequenceNum:(NSString *)aSn error:(NSError *)aError{
    [_channel invokeMethod:@"didAliasAction" arguments:@{@"action":action,@"isSuccess":@(isSuccess),@"sequenceNum":aSn,@"aError":aError}];

}

/**
 * 查询当前绑定tag结果返回
 * @param aTags   当前绑定的 tag 信息
 * @param aSn     返回 queryTag 接口中携带的请求序列码，标识请求对应的结果返回
 * @param aError  成功返回nil,错误返回相应error信息
 */
- (void)GetuiSdkDidQueryTag:(NSArray*)aTags sequenceNum:(NSString *)aSn error:(NSError *)aError{
    [_channel invokeMethod:@"didQueryTag" arguments:@{@"aTags":aTags,@"sequenceNum":aSn,@"sequenceNum":aSn,@"aError":aError}];
}

/**
 *  SDK遇到错误消息返回error
 *
 *  @param error SDK内部发生错误，通知第三方，返回错误
 */
- (void)GeTuiSdkDidOccurError:(NSError *)error{
    [_channel invokeMethod:@"didOccurError" arguments:@{@"error":error}];
}
#pragma mark - application delegate
/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // [3]:向个推服务器注册deviceToken 为了方便开发者，建议使用新方法
    [GeTuiSdk registerDeviceTokenData:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // 将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    [_channel invokeMethod:@"didReceiveRemoteNotification" arguments:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSLog(@"willPresentNotification：%@", notification.request.content.userInfo);
    
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}
//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSLog(@"didReceiveNotification：%@", response.notification.request.content.userInfo);
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    [_channel invokeMethod:@"didReceiveRemoteNotification" arguments:response.notification.request.content.userInfo];
    completionHandler();
}
#endif
@end
