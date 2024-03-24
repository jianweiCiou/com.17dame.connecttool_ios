# com.17dame.connecttool_ios
17dame cocos2d connecttool 

## Prerequisites
### Minimum requirements  
Your application needs to support :
- Minimum SDK version 26
- Android Gradle Plugin Version: 4.0.1
- Gradle Version : 6.1.1
- ABI :armeabi-v7a, arm64-v8a



## AAR 安裝
- 下載點:[connecttool-v1.4.0.aar](https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/Tutorial/connecttool-v1.4.0.aar)
- connectcocos\proj.android\app 資料夾中加入 libs , 放入 aar
- build.gradle 的 dependencies 加入
```
    // ConnectTool http request
    implementation 'com.squareup.retrofit2:retrofit:2.1.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.1.0'
    implementation 'com.squareup.okhttp3:logging-interceptor:3.4.1'
    implementation 'com.squareup.okhttp3:okhttp:3.4.1'
    // 使用 aar
    implementation files('libs/connecttool-debug.aar')
```

## Setting
- add BroadcastReceiver:
```xml
<!-- 加入 CONNECT_ACTION -->
<receiver android:name="com.r17dame.connecttool.ConnectToolBroadcastReceiver" android:exported="true">
    <intent-filter>
        <action android:name="com.r17dame.CONNECT_ACTION"/>
    </intent-filter>
</receiver>
```

## 發行版本切換
- 測試版 : _connectTool.setToolVersion(ConnectTool.TOOL_VERSION.testVS)
- 正式版 : _connectTool.setToolVersion(ConnectTool.TOOL_VERSION.releaseVS)


## Cocos2dxActivity 設定
### 參數
```java
    // 取得網頁事件回應
    private ConnectToolBroadcastReceiver connectReceiver;
    // Cocos2d 呼應實體
    private static AppActivity connect17dameActivity;
    // 17 dame 工具
    ConnectTool _connectTool;
    private final static String TAG = "ConnectTool test";
    IntentFilter itFilter;
```
### onCreate 初始
- tool 初始 : [說明](https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/README.md#connecttool-function)
- 版本 : 
```java
_connectTool.setPlatformVersion(ConnectTool.PLATFORM_VERSION.cocos2dVS);
_connectTool.setToolVersion(ConnectTool.TOOL_VERSION.testVS);
```
- 網頁與 BroadcastReceiver
```java
	// 設定 17dame 網頁
        _connectTool.connectCocos_webLayout = new FrameLayout(this);
        addContentView(_connectTool.connectCocos_webLayout, _connectTool.getFrameLayoutParams());

        // Init 17dame registerReceiver
        itFilter = new IntentFilter();
        itFilter.addAction("com.r17dame.CONNECT_ACTION");
        connectReceiver = new ConnectToolBroadcastReceiver();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // 修正 Android 14+ 的廣播註冊
            this.registerReceiver(connectReceiver, itFilter, RECEIVER_EXPORTED);
        } else {
            registerReceiver(connectReceiver, itFilter);
        }
```
- '登入完成', '儲值完成', '消費完成'相關事件的回應
```java
connectReceiver.registerCallback(new ConnectToolBroadcastReceiver.ConnectToolReceiverCallback() {
            @Override
            public void connectToolPageBack(Intent intent, String accountBackType) {
                String backType = intent.getStringExtra("accountBackType"); 
                if (backType.equals("CompletePurchase")) {
                    _connectTool.appLinkDataCallBack_CompletePurchase(intent, value -> {
                         儲值完成
                    });
                } 
                // Complete consumption of SP Coin
                if (backType.equals("CompleteConsumeSP")) {
                    UUID queryConsumeSP_requestNumber = UUID.randomUUID(); // App-side-RequestNumber(UUID), default random
                    // consume_transactionId
                    _connectTool.appLinkDataCallBack_CompleteConsumeSP(intent, queryConsumeSP_requestNumber, value -> {
                         消費完成
                    });
                }

                // get Access token
                if (backType.equals("Authorize")) {
                    UUID GetMe_RequestNumber = UUID.randomUUID(); // App-side-RequestNumber(UUID), default random
                    String state = "App-side-State";
                    _connectTool.appLinkDataCallBack_OpenAuthorize(intent, state, GetMe_RequestNumber, value -> {
                        登入完成
                    });
                }
            }
        }); 
```
- 取消 Connect Receiver
```java
@Override
    public void onDestroy() {
        super.onDestroy();
        // region ****************** 17dame tool ********************************
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // 修正 Android 14+ 的廣播註冊
            this.registerReceiver(connectReceiver, itFilter, RECEIVER_EXPORTED);
        } else {
            unregisterReceiver(connectReceiver);
        }
        // endregion ****************** 17dame tool ********************************
    }
```

## 登入 / 註冊 
### 呼叫範例
```cpp
JniMethodInfo minfo;
bool isHave = JniHelper::getStaticMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity", "getConnect17dameInstance", "()Lorg/cocos2dx/cpp/AppActivity;");
jobject jobj;
if (isHave) { 
  		jobj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
  		isHave = JniHelper::getMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity", "openLoginWebview", "(Ljava/lang/String;)V");
    
  		if (isHave) {
        //  
        jstring jState = minfo.env->NewStringUTF("App-side-State"); 
  			minfo.env->CallVoidMethod(jobj, minfo.methodID, jState);
  		}
} 
```
- state : 請填寫要驗證的內容
### 參考
- [說明](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#openauthorizeurl)
- 登入完成獲得資料 :  [登入後的資料內容](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#authorize-subsequent-events)


## 取得用戶資訊 
### 呼叫範例
```cpp
JniMethodInfo minfo;
bool isHave = JniHelper::getStaticMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity", "getConnect17dameInstance", "()Lorg/cocos2dx/cpp/AppActivity;");
jobject jobj;
if (isHave) {
	jobj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
	isHave = JniHelper::getMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity", "GetMeInfo", "()V");

	if (isHave) {
		minfo.env->CallVoidMethod(jobj, minfo.methodID);
	}
}
```
- [用戶資訊格式](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#openauthorizeurl)


## 儲值 SP
### 呼叫範例
```cpp
JniMethodInfo minfo;
bool isHave = JniHelper::getStaticMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity", "getConnect17dameInstance", "()Lorg/cocos2dx/cpp/AppActivity;");
jobject jobj;
if (isHave) {
    jobj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
    isHave = JniHelper::getMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity", "openRechargeSPWebview", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
    if (isHave) {  
        jstring currencyCode = minfo.env->NewStringUTF("2"); // TWD
        jstring notifyUrl = minfo.env->NewStringUTF(""); // notifyUrl 
        jstring state = minfo.env->NewStringUTF("Custom state"); 
         
        minfo.env->CallVoidMethod(jobj, minfo.methodID, currencyCode, notifyUrl, state);
    }
}
```
- currencyCode : 目前 TWD 帶入 2 ([幣種對照](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#currency-code))
- notifyUrl : 遊戲開發者自訂的 URL ([Notifyurl 說明](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#notifyurl--state))
- state : 請填寫要驗證的內容
  
### 測試資料
- 測試卡號 : 4111111111111111
- 有效年月 : 11/24
- 末三碼 : 111
- OTP 密碼七碼 : 直接點選手機接收，然後輸入 OTP 密碼七碼 1234567
### 參考
[儲值說明](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#open-recharge-page)

## 消費 SP
### 呼叫範例
```cpp
 JniMethodInfo minfo;
 bool isHave = JniHelper::getStaticMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity", "getConnect17dameInstance", "()Lorg/cocos2dx/cpp/AppActivity;");
 jobject jobj;
 if (isHave) {
     jobj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
     isHave = JniHelper::getMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity", "openConsumeSPWebview", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
     if (isHave) {
         jint consume_spCoin = 10;  
         jstring orderNo = minfo.env->NewStringUTF(""); 
         jstring productName = minfo.env->NewStringUTF("productName"); 
         jstring GameName = minfo.env->NewStringUTF("GameName");  
         jstring notifyUrl = minfo.env->NewStringUTF("");  
         jstring state  = minfo.env->NewStringUTF("state");
         jstring requestNumber = minfo.env->NewStringUTF("91f039df-eb20-4682-a56c-4ccb7c37db16");
          
         minfo.env->CallVoidMethod(jobj, minfo.methodID, consume_spCoin, orderNo, GameName, productName, notifyUrl, state, requestNumber);
     }
 }
```
- consume_spCoin : 商品定價
- orderNo : 遊戲開發者自訂的 OrderNo, String 格式
- productName : 商品名稱
- GameName : 遊戲名稱
- notifyUrl : 遊戲開發者自訂的 URL (https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#notifyurl--state)
- state : 請填寫要驗證的內容
- requestNumber : UUID

### 開啟頁面
[消費說明](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#open-consumesp-page)

### 遊戲 Server 端驗證方式
- [驗證流程參考](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#consumesp-flow)
- 請於將 NotifyUrl 設定為遊戲 Server 端網址, 消費者扣除 SP 後會發送通知到此網址
- NotifyCheck : 請回應 "ok" 或是 "true" 即可
- NotifyCheck  [參考](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#notifycheck)


