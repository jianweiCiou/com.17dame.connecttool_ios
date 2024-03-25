
//simport UIKit
import Foundation
import WebKit
import SwiftUI
import ObjCConnectTool
import cxxLibrary

public class ConnectToolBlack {
    
    /// Tool 版本, 分測試與發行
    public enum TOOL_VERSION : CustomStringConvertible {
        case testVS
        case releaseVS
        
        public var description : String {
            switch self {
            case .testVS: return "testVS"
            case .releaseVS: return "releaseVS"
            }
        }
    }
    
    /// 平台版本
    public enum PLATFORM_VERSION : CustomStringConvertible {
        case nativeVS
        case cocos2dVS
        
        public var description : String {
            switch self {
                // Use Internationalization, as appropriate.
            case .nativeVS: return "nativeVS"
            case .cocos2dVS: return "cocos2dVS"
            }
        }
    }
    
    public static var Secret = "";
    public static var ClientID = "";
    public static var Game_id = "";
    public static var _me = "";
    public static var access_token = "";
    public static var RSAstr = "";
    public static var requestNumber = "";
    public static var notifyUrl = "";
    public static var redirect_uri = "";
    public static var referralCode = "16888";
    
    
    private var rootVC: UIViewController?
    
    private lazy var onboardingViewController: WebViewController = {
        let controller = WebViewController()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        return controller
    }()
    
    var connectBasic: ConnectBasic
    var apiClient_objc : APIClient_objc
    var payMentBaseurl = "https://gamar18portal.azurewebsites.net"
    var spCoinItemPriceId = ""
    var prime = ""
    var code = ""
    var access_token = ""
    var refresh_token = ""
    var payMethod = ""
    var isRunAuthorize = false;
    
    public static var toolVersion = TOOL_VERSION.testVS
    public static var platformVersion = PLATFORM_VERSION.nativeVS
    
    /// 工具初始
    /// - Parameters:
    ///   - _redirect_uri: 遊戲 redirect 辨識
    ///   - _RSAstr: 單位 Key
    ///   - _client_id: 單位 id
    ///   - _X_Developer_Id: 開發  id
    ///   - _client_secret: 單位密鑰
    ///   - _Game_id: 遊戲 id
    ///   - _toolVersion: 遊戲 id
    ///   - _platformVersion: 平台版本
    public init(_redirect_uri: String,
                _RSAstr: String,
                _client_id : String,
                _X_Developer_Id : String,
                _client_secret : String,
                _Game_id : String,
                _platformVersion:PLATFORM_VERSION )
    {
        // 預設為測試
        let _toolVersion = TOOL_VERSION.testVS;
        
        payMethod = "1"
        
        payMentBaseurl = "https://gamar18portal.azurewebsites.net"
        
        // Payment
        spCoinItemPriceId = ""
        prime = ""
        code = ""
        access_token = ""
        refresh_token = ""
        payMethod = ""
        
        // api
        apiClient_objc = APIClient_objc()
        
        ConnectToolBlack.toolVersion = _toolVersion
        ConnectToolBlack.platformVersion = _platformVersion
        
        if(_toolVersion == TOOL_VERSION.testVS){
            APIClient.host = "gamar18portal.azurewebsites.net"
        }else{
            APIClient.host = "17dame.com"
        }
        
        connectBasic = ConnectBasic(
            client_id: _client_id,
            X_Developer_Id: _X_Developer_Id,
            client_secret: _client_secret,
            Game_id:_Game_id,
            referralCode:ConnectToolBlack.referralCode
        )
        
        // init
        ConnectToolBlack.redirect_uri = "https://" + APIClient.host + "/Account/connectlink";
        ConnectToolBlack.RSAstr = _RSAstr
        ConnectToolBlack.ClientID = _client_id
        ConnectToolBlack.Game_id = _Game_id
        ConnectToolBlack.access_token = Configuration.value(defaultValue: "", forKey: access_token)
        ConnectToolBlack.requestNumber = UUID().uuidString
        ConnectToolBlack.Secret = _client_secret
    }
    
    /// 設定平台 native or cocos2d
    /// - Parameters:
    ///   - _platformVersion: 原生或遊戲
    public func setPlatformVersion( _platformVersion:PLATFORM_VERSION) {
        ConnectToolBlack.platformVersion = _platformVersion;
    }
    
    
    /// 設定發行板或是測試版
    /// - Parameters:
    ///   - _toolVersion:  版本
    public func setToolVersion( _toolVersion:TOOL_VERSION) {
        ConnectToolBlack.toolVersion = _toolVersion;
        
        if (ConnectToolBlack.toolVersion == TOOL_VERSION.testVS) {
            APIClient.host = "gamar18portal.azurewebsites.net"
            APIClient.game_api_host = "r18gameapi.azurewebsites.net"
        } else {
            APIClient.host = "www.17dame.com"
            APIClient.game_api_host = "gameapi.17dame.com"
            
            ConnectToolBlack.redirect_uri = "https://" + APIClient.host + "/Account/connectlink";
        }
    }
    
    /// 開啟登入與註冊頁面
    /// - Parameters:
    ///   - _state:  state
    ///   - rootVC:  state
    public func OpenAuthorizeURL( _state:String,rootVC: UIViewController) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIClient.host
        components.path = "/connect/Authorize"
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: connectBasic.client_id),
            URLQueryItem(name: "redirect_uri", value: ConnectToolBlack.redirect_uri),
            URLQueryItem(name: "scope", value: "game+offline_access"),
            URLQueryItem(name: "state", value: _state)
        ]
        openhostPage(url:components.url!,rootVC:rootVC)
    }
    
    public func SwitchAccountURL(  rootVC: UIViewController) {
        Configuration.value(value: "0", forKey: "expiresTs")
        Configuration.value(value: "", forKey: "access_token")
        Configuration.value(value: "", forKey: "refresh_token")
        
        OpenLoginURL(rootVC:rootVC)
    }
    
    public func OpenLoginURL(  rootVC: UIViewController) {
        let url = getLoginURL();
        openhostPage(url:url,rootVC:rootVC)
    }
    
    public func getLoginURL() -> URL {
        
        let _redirect_uri = ConnectToolBlack.redirect_uri + "?accountBackType=Login";
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIClient.host
        components.path = "/account/AppLogin/\(connectBasic.Game_id)/\(ConnectToolBlack.referralCode)"
        components.queryItems = [
            URLQueryItem(name: "returnUrl", value: _redirect_uri)
        ]
        return components.url!
    }
    
    
    
    /// 開啟儲值頁面
    /// - Parameters:
    ///   - currencyCode:  (說明參考 [here](https://github.com/jianweiCiou/com.17dame.connecttool_android/tree/main?tab=readme-ov-file#currency-code))
    ///   - _notifyUrl:  NotifyUrl is a URL customized by the game developer.
    ///   - state:  (說明參考 [here](https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/README.md#open-recharge-page))
    public func OpenRechargeURL(currencyCode:String,  _notifyUrl:String,  state:String,rootVC: UIViewController) {
        let  url = getRechargeURL(currencyCode:currencyCode, _notifyUrl:_notifyUrl, state:state);
        
        if (isOverExpiresTs()) {
            GetRefreshToken_Coroutine(){ token in
                self.openhostPage(url: url,rootVC:rootVC)
            }
        } else {
            openhostPage(url:url,rootVC:rootVC)
        }
    }
    
    
    public func getRechargeURL(currencyCode:String,  _notifyUrl:String,  state:String )  -> URL {
        var notifyUrl:String = ""
        if(_notifyUrl == ""){
            notifyUrl = "none_notifyUrl"
        }else{
            notifyUrl = _notifyUrl
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIClient.host
        components.path = "/MemberRecharge/Recharge"
        components.queryItems = [
            URLQueryItem(name: "X_Developer_Id", value: Tool.urlEncoded(connectBasic.X_Developer_Id)),
            URLQueryItem(name: "accessScheme", value: Tool.urlEncoded(ConnectToolBlack.redirect_uri)),
            URLQueryItem(name: "accessType", value: "2"),
            URLQueryItem(name: "currencyCode", value: currencyCode),
            URLQueryItem(name: "notifyUrl", value: notifyUrl),
            URLQueryItem(name: "state", value: Tool.urlEncoded(state)),
            URLQueryItem(name: "referralCode", value: ConnectToolBlack.referralCode)
        ]
        
        return components.url!
    }
    
    /**
     * Open ConsumeSP page.
     *
     * @param consume_spCoin - SP Coin
     * @param orderNo        - Must be unique,Game developers customize
     * @param GameName       - GameName
     * @param productName    - Product Name
     * @param _notifyUrl     - <a href="https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/README.md#notifyurl--state">NotifyUrl is a URL customized by the game developer. We will post NotifyUrl automatically when the purchase is completed</a>
     * @param state          - <a href="https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/README.md#notifyurl--state">State is customized by game developer, which will be returned to game app after purchase complete. (Deeplink QueryParameter => purchase_state)</a>
     * @see <a href="https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/README.md#open-consumesp-page">Description</a>
     */
    /// 開啟消費頁面
    /// - Parameters:
    ///   - consume_spCoin:  (說明參考
    public func OpenConsumeSPURL( consume_spCoin:Int,  orderNo:String,  GameName:String,  productName:String,  _notifyUrl:String,  state:String,  requestNumber:String,rootVC: UIViewController) {
        
        var _orderNo = orderNo;
        if (_orderNo == "") {
            _orderNo = UUID().uuidString;
        }
        
        let url = getConsumeSPURL(  consume_spCoin: consume_spCoin, orderNo: orderNo, GameName: GameName, productName: productName, _notifyUrl: _notifyUrl, state: state, requestNumber: requestNumber);
        ConnectToolBlack.requestNumber = requestNumber
        ConnectToolBlack.notifyUrl = _notifyUrl
        
        if (isOverExpiresTs()) {
            // token 到期
            GetRefreshToken_Coroutine(){ token in
                self.openhostPage(url: url,rootVC:rootVC)
            }
        } else {
            openhostPage(url: url,rootVC:rootVC)
        }
    }
    
    
    public func getConsumeSPURL(consume_spCoin:Int,  orderNo:String,  GameName:String,  productName:String,  _notifyUrl:String,  state:String,  requestNumber:String) -> URL {
        
        // 儲存 SharedPreferences
        Configuration.value(value: requestNumber, forKey: "requestNumber")
        
        var notifyUrl = _notifyUrl
        
        if(_notifyUrl == "")
        {
            notifyUrl = "none_notifyUrl"
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIClient.host
        components.path = "/member/consumesp"
        components.queryItems = [
            URLQueryItem(name: "xDeveloperId", value: connectBasic.X_Developer_Id),
            URLQueryItem(name: "accessScheme", value: ConnectToolBlack.redirect_uri),
            URLQueryItem(name: "accessType", value: "2"),
            URLQueryItem(name: "gameId", value: connectBasic.Game_id),
            URLQueryItem(name: "gameName", value: GameName),
            URLQueryItem(name: "orderNo", value: orderNo),
            URLQueryItem(name: "productName", value: productName),
            URLQueryItem(name: "consumeSpCoin", value: "\(consume_spCoin)"),
            URLQueryItem(name: "consumeRebate", value:"0"),
            URLQueryItem(name: "notifyUrl", value:notifyUrl),
            URLQueryItem(name: "state", value:state),
            URLQueryItem(name: "referralCode", value:ConnectToolBlack.referralCode)
        ]
        
        return components.url!
    }
    
    //====================
    
    /// Set notifyUrl and state. (Optional)
    /// - Parameters:
    ///   - notifyUrl: NotifyUrl is a URL customized by the game developer.
    ///   - state: (說明參考 [here](https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/README.md#open-recharge-page))
    public func set_purchase_notifyData(notifyUrl:String,state:String) {
        //set
        Configuration.value(value: notifyUrl, forKey: "purchase_notifyUrl")
        Configuration.value(value: state, forKey: "purchase_state")
    }
    
    /**
     * OpenAuthorize Callback
     *
     * @param notification
     * @param _state
     * @param GetMe_RequestNumber
     * @param authCallback
     */
    public  func appLinkDataCallBack_OpenAuthorize(notification: Notification,  _state:String,  GetMe_RequestNumber:UUID,with authCallback:@escaping (AuthorizeInfo) -> Void )
    {
        let code = notification.userInfo?["code"]  as! String;
        
        
        GetConnectToken_Coroutine(_code:code){ _connectToken in
            let _access_token = _connectToken.access_token;
            
            
            self.GetMe_Coroutine(_GetMeRequestNumber: GetMe_RequestNumber)
            {me in
                self.isRunAuthorize = false;
                
                let _auth = AuthorizeInfo(meInfo: me, connectToken: _connectToken, state: _state, access_token: _access_token);
                
                authCallback(_auth);
            };
        }
    }
    
    
    
    public func GetConnectToken_Coroutine(_code:String,connectTokenCall: @escaping (ConnectToken) -> Void ) {
        // 取得 token
        APIClient.getConnectToken(_connectToolBlack: self,
                                  connectBasic: self.connectBasic,
                                  _code: _code,
                                  redirect_uri: ConnectToolBlack.redirect_uri)
        { tokenData in
            let access_token = tokenData.access_token;
            let refresh_token = tokenData.refresh_token;
            // 儲存時間
            Tool.saveExpiresTs(tokenData_expires_in:tokenData.expires_in);
            // 儲存tokeen
            Configuration.value(value: access_token, forKey: "access_token")
            Configuration.value(value: refresh_token, forKey: "refresh_token")
            
            connectTokenCall(tokenData);
        }
    }
    
    /**
     * Get MeInfo
     *
     * @param _GetMeRequestNumber - App-side-RequestNumber(UUID)
     * @param callback            -
     * @see <a href="https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/README.md#query-consumesp-by-transactionid">說明</a>
     */
    public func GetMe_Coroutine( _GetMeRequestNumber:UUID, callback: @escaping (MeInfo) -> Void){
        if (isOverExpiresTs()) {
            // 無 token
            // token 到期
            GetRefreshToken_Coroutine(){ token in
                self.getMeData(_GetMeRequestNumber:_GetMeRequestNumber){
                    me in
                    callback(me)
                };
            }
        } else {
            getMeData(_GetMeRequestNumber:_GetMeRequestNumber){
                me in
                callback(me)
            };
        }
    }
    
    // APIClient
    public func getMeData( _GetMeRequestNumber:UUID,
                           callbackMeInfo: @escaping (MeInfo) -> Void){
        
        APIClient.getMe(_connectToolBlack: self,   X_Developer_Id: self.connectBasic.X_Developer_Id, RequestNumber: _GetMeRequestNumber.uuidString , GameId: self.connectBasic.Game_id, ReferralCode: ConnectToolBlack.referralCode) { me in
            callbackMeInfo(me)
        }
    }
    
    
    public func GetRefreshToken_Coroutine(connectTokenCall: @escaping (ConnectToken) -> Void ) {
        
        if (!_checkConstructorParametersComplete()) {
            return;
        }
        
        let refresh_token = Configuration.value(defaultValue: "", forKey: "refresh_token")
        
        APIClient.getRefreshTokenData(_connectToolBlack: self, connectBasic: self.connectBasic, refresh_token: refresh_token, redirect_uri: ConnectToolBlack.redirect_uri)
        { tokenData in
            let access_token = tokenData.access_token;
            let refresh_token = tokenData.refresh_token;
            
            // 儲存時間
            Tool.saveExpiresTs(tokenData_expires_in:tokenData.expires_in);
            
            // 儲存tokeen
            Configuration.value(value: access_token, forKey: "access_token")
            Configuration.value(value: refresh_token, forKey: "refresh_token")
            
            connectTokenCall(tokenData);
        }
    }
    
    public func AccountPageEvent( authorizeState:String,  accountBackType:String,rootVC: UIViewController) {
        if (accountBackType == "Register") {
            OpenAuthorizeURL(_state:authorizeState,rootVC: rootVC);
        }
        if (accountBackType == "Login") {
            OpenAuthorizeURL(_state:authorizeState,rootVC: rootVC);
        }
    }
    
    private func openhostPage(url:URL,rootVC: UIViewController ) {
        self.rootVC = rootVC
        rootVC.present(onboardingViewController, animated: true, completion: nil)
        onboardingViewController.openURLPage(url:url)
    }
    
    private func isOverExpiresTs() -> Bool{
        let expiresTs = Configuration.value(defaultValue: "", forKey: "expiresTs")
        let access_token = Configuration.value(defaultValue: "", forKey: "access_token")
        let refresh_token = Configuration.value(defaultValue: "", forKey: "refresh_token")
        
        
        if (expiresTs == "" || access_token == "" || refresh_token == "") {
            return true;
        } else {
            let expiresTsDouble = Double(expiresTs) ?? 0.0
            
            let currentTs = NSDate().timeIntervalSince1970 / 1000;
            let currentTsDouble = Double(currentTs);
            
            if (currentTsDouble > expiresTsDouble) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    private func _checkConstructorParametersComplete() ->Bool{
        if (ConnectToolBlack.redirect_uri == "") {
            return false;
        }
        if (ConnectToolBlack.RSAstr == "") {
            return false;
        }
        if (connectBasic.X_Developer_Id == "") {
            return false;
        }
        if (connectBasic.client_secret == "") {
            return false;
        }
        if (connectBasic.Game_id == "") {
            return false;
        }
        return true;
    }
    
}

extension UIViewController {
    
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}
