import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getui_push_plugin/getui_push_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('getui_push_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await GetuiPushPlugin.platformVersion, '42');
  });
}
