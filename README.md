# com.17dame.connecttool_ios
17dame iOS connecttool 

## Prerequisites
### Minimum requirements  
Your application needs to support :
- Minimum iOS version : 13

## 安裝
-  File > Add Package Dependency
-  填入 https://github.com/jianweiCiou/com.17dame.connecttool_ios
-  選擇 ConnectTool
![image](https://github.com/jianweiCiou/com.17dame.connecttool_ios/blob/main/images/connectselect.png?raw=true)

## Setting   
### 加入 ConnectToolConfig
- Add ConnectToolConfig.xcconfig to App Project > Configurations > Debug & Release
![image](https://github.com/jianweiCiou/com.17dame.connecttool_ios/blob/main/images/add_config.png?raw=true)

- 進 Project 進行配置
![image](https://github.com/jianweiCiou/com.17dame.connecttool_ios/blob/main/images/set_config.png?raw=true)

- 填入對應資料
```txt
X_Developer_Id = 
client_secret = 
redirect_uri = 
Game_id = 
```

- Info.plist 增加數據
```XML 
    <key>X_Developer_Id</key>
    <string>$(X_Developer_Id)</string>
    <key>client_secret</key>
    <string>$(client_secret)</string>
    <key>redirect_uri</key>
    <string>$(redirect_uri)</string>
    <key>Game_id</key>
    <string>$(Game_id)</string>  
```
![image](https://github.com/jianweiCiou/com.17dame.connecttool_ios/blob/main/images/plist.png?raw=true)



## ViewController 佈局
### ConnectTool 初始
- 工具初始
- 設定測試與正式
- 註冊 17dame NotificationCenter 應用事件
```swift
import ConnectTool
override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 工具初始
        let RSAstr = "...";
        
        let X_Developer_Id = Bundle.main.infoDictionary?["X_Developer_Id"]
        let client_secret = Bundle.main.infoDictionary?["client_secret"]
        let redirect_uri = Bundle.main.infoDictionary?["redirect_uri"]
        let Game_id = Bundle.main.infoDictionary?["Game_id"]
        
        self._connectTool = ConnectToolBlack(_redirect_uri : redirect_uri as! String,
                                             _RSAstr : RSAstr,
                                             _client_id : X_Developer_Id as! String,
                                             _X_Developer_Id : X_Developer_Id as! String,
                                             _client_secret : client_secret as! String,
                                             _Game_id : Game_id as! String,
                                             _platformVersion: ConnectToolBlack.PLATFORM_VERSION.nativeVS );
        
        // 設定測試與正式
        self._connectTool?.setToolVersion(_toolVersion: ConnectToolBlack.TOOL_VERSION.testVS);
        //self._connectTool?.setToolVersion(_toolVersion:ConnectToolBlack.TOOL_VERSION.releaseVS);
        
        // 註冊 17dame 應用事件
        NotificationCenter.default.addObserver(self, selector: #selector(r17dame_ReceiverCallback),name: NSNotification.Name .r17dame_ReceiverCallback, object: nil)
    }
```

- 移除 17dame 應用事件的訂閱 
```swift
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.r17dame_ReceiverCallback, object: nil)
    }
```
- 17dame 應用事件回應 : 完成登入, 完成註冊, 完成儲值, 完成消費
```swift
    d@objc func r17dame_ReceiverCallback(_ notification: Notification){
        let backType = notification.userInfo?["accountBackType"]  as! String;
        
        // Complete purchase of SP Coin
        if (backType  ==  "CompletePurchase") {
            let TradeNo = notification.userInfo?["TradeNo"]  as! String;
            let PurchaseOrderId = notification.userInfo?["PurchaseOrderId"]  as! String;
            
            print("完成儲值 ")
            print("TradeNo : " +  TradeNo)
            print("PurchaseOrderId : " +  PurchaseOrderId)
        }
        
        // Complete consumption of SP Coin
        if (backType  ==  "CompleteConsumeSP") {
            let consume_status = notification.userInfo?["consume_status"]  as! String;
            let transactionId = notification.userInfo?["transactionId"]  as! String;
            let orderNo = notification.userInfo?["orderNo"]  as! String;
            let productName = notification.userInfo?["productName"]  as! String;
            let spCoin = notification.userInfo?["spCoin"]  as! Int;
            let rebate = notification.userInfo?["rebate"]  as! Int;
            let orderStatus = notification.userInfo?["orderStatus"]  as! String;
            let state = notification.userInfo?["state"]  as! String;
            let notifyUrl = notification.userInfo?["notifyUrl"]  as! String;
            
            print("完成消費 ")
            print("consume_status : " +  consume_status)
            print("transactionId : " +  transactionId)
            print("orderNo : " +  orderNo)
            print("productName : " +  productName)
            print("spCoin : \(spCoin)"   )
            print("rebate : \(rebate)"   )
            print("orderStatus : " +  orderStatus)
            print("state : " +  state)
            print("notifyUrl : " +  notifyUrl)
        }
        
        // get Access token
        if(backType == "Authorize"){
            let GetMe_RequestNumber = UUID();
            let state = "App-side-State";
            _connectTool?.appLinkDataCallBack_OpenAuthorize(
                notification:notification,
                _state:state,
                GetMe_RequestNumber:GetMe_RequestNumber
            ){
                /*
                 * App-side add functions.
                 */
                auth in
                print("Authorize 回應")
                print("userId : " + auth.meInfo.data.userId)
                print("email : " + auth.meInfo.data.email)
                print("spCoin : \(auth.meInfo.data.spCoin)")
                print("rebate : \(auth.meInfo.data.rebate)")
            }
        }
    }
```

## 發行版本切換
- 測試版 : 
```swift 
	self._connectTool?.setToolVersion(_toolVersion: ConnectToolBlack.TOOL_VERSION.testVS); 
```
- 正式版 : _connectTool.setToolVersion(ConnectTool.TOOL_VERSION.releaseVS)
```swift
	self._connectTool?.setToolVersion(_toolVersion:ConnectToolBlack.TOOL_VERSION.releaseVS);
```

 
## NotificationCenter 相關設定
### 
```swift 
extension Notification.Name {
    static var r17dame_ReceiverCallback: Notification.Name {
        return .init(rawValue: "com.r17dame.CONNECT_ACTION.ReceiverCallback") }
}
```
 


## 登入 / 註冊 
### 呼叫範例
```swift 
    @IBAction func OpenAuthorizeURL(_: Any) {
        let state:String = "App-side-State";
        self._connectTool?.OpenAuthorizeURL(_state: state,rootVC: self)
    }
```
- state : 請填寫要驗證的內容
### 參考
- [說明](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#openauthorizeurl)
- 登入完成獲得資料 :  [登入後的資料內容](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#authorize-subsequent-events)


## 取得用戶資訊 
### 呼叫範例
```cpp 
    @IBAction func GetMe_Coroutine(_: Any) {
        let GetMe_RequestNumber = UUID(); // App-side-RequestNumber(UUID), default random
        _connectTool?.GetMe_Coroutine(_GetMeRequestNumber: GetMe_RequestNumber, callback: { MeInfo in
            print("取用戶登入資料")
            print("userId : " + MeInfo.data.userId)
            print("email : " + MeInfo.data.email)
            print("nickName : " + (MeInfo.data.nickName ?? ""))
            print("spCoin : \(MeInfo.data.spCoin)")
            print("rebate : \(MeInfo.data.rebate)")
            print("avatarUrl : " + (MeInfo.data.avatarUrl ?? ""))
        })
    }
```
- [用戶資訊格式](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#openauthorizeurl)


## 儲值 SP
### 呼叫範例
```swift
@IBAction func OpenRechargeURL(_: Any) {
        let notifyUrl = "";// NotifyUrl is a URL customized by the game developer
        let state = "Custom state";// Custom state
        
        _connectTool?.set_purchase_notifyData(notifyUrl:notifyUrl,state:state);
        
        // Step2. Set currencyCode
        let currencyCode = "2";
        
        // Step3. Open Recharge Page
        _connectTool?.OpenRechargeURL(currencyCode:currencyCode,_notifyUrl: notifyUrl,state: state,rootVC: self);
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
```swift
@IBAction func OpenConsumeSPURL(_: Any) {
        let notifyUrl = "";// NotifyUrl is a URL customized by the game developer
        let state = UUID().uuidString; // Custom state , default random_connectTool.set_purchase_notifyData(notifyUrl, state);
        
        _connectTool?.set_purchase_notifyData(notifyUrl:notifyUrl,state:state);
        
        let  consume_spCoin = 10;
        let orderNo = UUID().uuidString; // orderNo is customized by the game developer
        let requestNumber = UUID().uuidString; // requestNumber is customized by the game developer, default random
        let GameName = "GameName";
        let productName = "productName";
        _connectTool?.OpenConsumeSPURL(consume_spCoin: consume_spCoin, orderNo: orderNo, GameName: GameName, productName: productName, _notifyUrl: notifyUrl, state: state, requestNumber: requestNumber,rootVC: self);
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


