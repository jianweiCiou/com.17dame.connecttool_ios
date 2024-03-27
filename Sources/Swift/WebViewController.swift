//
//  WebViewController.swift
//  
// https://medium.com/ting-chien/ios%E9%96%8B%E7%99%BC-%E5%85%A7%E5%B5%8Cwkwebview%E4%BE%86%E5%92%8C%E7%B6%B2%E9%A0%81%E4%BA%92%E5%8B%95-f99e5fab804a
//  Created by Jianwei Ciou on 2024/3/3.
//

//import UIKit
import WebKit


@available(iOS 14.0, *)
class WebViewController: UIViewController,UINavigationBarDelegate,WKNavigationDelegate, WKUIDelegate {
     
    // 頁面功能
    let sendFinish_funcName = "sendFinish"
      
    lazy var webView: WKWebView = {
        
        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true
        
        let pres = WKWebpagePreferences()
        pres.allowsContentJavaScript = true
        
        // configuration
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = pres
        configuration.userContentController = WKUserContentController()
        configuration.userContentController.add(self, name: "iOS17dame")
        configuration.userContentController.add(self, name: "sendFinish")
        configuration.userContentController.add(self, name: "Android")
        configuration.userContentController.add(self, name: "CompleteLogin")
        configuration.userContentController.add(self, name: "CompleteRegistration")
        configuration.userContentController.add(self, name: "locationHref")
        configuration.userContentController.add(self, name: "runSPCoinCreateOrder")
        configuration.userContentController.add(self, name: "getXSignature")
        configuration.userContentController.add(self, name: "appLinkDataCallBack_CompletePurchase")
        configuration.userContentController.add(self, name: "appLinkDataCallBack_CompleteConsumeSP") 
        //************************************************************************
        let me = Configuration.value(defaultValue: "", forKey:"me")
        let localStorageData: [String: Any] = [
            "RSAstr": ConnectToolBlack.RSAstr,
            "Secret" :ConnectToolBlack.Secret,
            "ClientID":ConnectToolBlack.ClientID,
            "me":me,
        ]
        if JSONSerialization.isValidJSONObject(localStorageData),
            let data = try? JSONSerialization.data(withJSONObject: localStorageData, options: []),
            let value = String(data: data, encoding: .utf8) {
            let script = WKUserScript(
                source: "Object.assign(window.localStorage, \(value));",
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
            // 5: Add created WKUserScript variable into the configuration
            configuration.userContentController.addUserScript(script)
        }
        //************************************************************************
        
        // 增加頁面 log
        let source = "document.addEventListener('message', function(e){ window.webkit.messageHandlers.iosListener.postMessage(e.data); })"
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(self, name: "iosListener")
        //************************************************************************
         
        let wv = WKWebView(frame: self.view.frame , configuration: configuration)
        wv.configuration.preferences = preferences
        wv.uiDelegate = self
        wv.navigationDelegate = self
        wv.translatesAutoresizingMaskIntoConstraints = false
        
        // Add observer
        wv.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
         
        
        return wv
    }()
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
     
    private lazy var connectContentView: ContentView = {
        let view = ContentView( )
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
         
        self.webView.navigationDelegate = self
         
//        let screenSize: CGRect = UIScreen.main.bounds
//            let myView = UIView(frame: CGRect(x: 0, y: 72, width: screenSize.width, height: screenSize.height-72))
//            self.view.addSubview(myView)
            
        
        addNavigationBar()
    }
    
    // 開頁面
    public func openURLPage(url:URL ) {
//        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true
        
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    private func addNavigationBar() {
        let height: CGFloat = 45
        let statusBarHeight: CGFloat = 45

        let navbar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: UIScreen.main.bounds.width, height: height))
        navbar.backgroundColor = UIColor.white
        navbar.delegate = self

        let navItem = UINavigationItem()
        navItem.title = ""
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissViewController))

        navbar.items = [navItem]
        view.addSubview(navbar)

        self.view?.frame = CGRect(x: 0, y: height, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - height))
    }
    
    @objc func dismissViewController(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
//            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
         
        
//        let newView = UIView()
//                self.view.addSubview(newView)
//                newView.translatesAutoresizingMaskIntoConstraints = false
//                if #available(iOS 11.0, *) {
//                    let guide = self.view.safeAreaLayoutGuide
//                    newView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
//                    newView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
//                    newView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
//                    newView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//                } else {
//                    NSLayoutConstraint(item: newView,
//                                       attribute: .top,
//                                       relatedBy: .equal,
//                                       toItem: view, attribute: .top,
//                                       multiplier: 1.0, constant: 0).isActive = true
//                    NSLayoutConstraint(item: newView,
//                                       attribute: .leading,
//                                       relatedBy: .equal, toItem: view,
//                                       attribute: .leading,
//                                       multiplier: 1.0,
//                                       constant: 0).isActive = true
//                    NSLayoutConstraint(item: newView, attribute: .trailing,
//                                       relatedBy: .equal,
//                                       toItem: view,
//                                       attribute: .trailing,
//                                       multiplier: 1.0,
//                                       constant: 0).isActive = true
//
//                        newView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//                }
        
    }
    
    /**
     確認網頁網址
     */
    var observeValueURL = ""
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            observeValueURL = "\(key)"         // Assign key-value to String
            if observeValueURL != ""{
                cURLChange(url: observeValueURL)   // Pass key-value to function
            }
        }
    }
    
    func cURLChange(url: String) {
         
        // Oauth 回應
        if observeValueURL.contains("Account/connectlink") {
            
            let accountBackType = getQueryStringParameter(url: url, param: "accountBackType")
            if((accountBackType ?? "").isEmpty == false){
                // auth
                if (accountBackType == "Register") {
                    let backTypeResponse = ["accountBackType":"Register" ]
                    NotificationCenter.default.post(name: NSNotification.Name.r17dame_ReceiverCallback,object: nil, userInfo:backTypeResponse as [AnyHashable : Any])
                    
                    finishWebPage();
                }
                if (accountBackType == "Login") {
                    let backTypeResponse = ["accountBackType":"Login" ]
                    NotificationCenter.default.post(name: NSNotification.Name.r17dame_ReceiverCallback,object: nil, userInfo:backTypeResponse as [AnyHashable : Any])
                    finishWebPage();
                }
            } 
            
            let code = getQueryStringParameter(url: url, param: "code")
            
            if((code ?? "").isEmpty == false){
                let backTypeResponse = ["accountBackType":"Authorize","code":code]
                
                NotificationCenter.default.post(name: NSNotification.Name.r17dame_ReceiverCallback,object: nil, userInfo:backTypeResponse as [AnyHashable : Any])
                finishWebPage()
            }
        }
    }
    
    
    private func finishWebPage() {
        if (ConnectToolBlack.platformVersion == ConnectToolBlack.PLATFORM_VERSION.nativeVS) {
            self.dismiss(animated: true)
        } else if (ConnectToolBlack.platformVersion == ConnectToolBlack.PLATFORM_VERSION.cocos2dVS) {
            self.dismiss(animated: true)
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    
    //*************************** WKUIDelegate *********************************************
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: () -> Void) {
        
        let alert = UIAlertController(title: "Tip", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //*************************** WKNavigationDelegate *********************************************
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let url = String(describing: webView.url)
        
//        print("didFinish + " + url)
        
        // 輸入 localStorage
        let access_token = Configuration.value(defaultValue: "", forKey:"access_token")
        
        webView.evaluateJavaScript("javascript:localStorage.setItem('Secret', '\(ConnectToolBlack.Secret)');", completionHandler: nil)
        webView.evaluateJavaScript("javascript:localStorage.setItem('ClientID', '\(ConnectToolBlack.ClientID)')", completionHandler: nil)
       
        webView.evaluateJavaScript("javascript:localStorage.setItem('access_token', '\(access_token)');", completionHandler: nil)
         
        webView.evaluateJavaScript("javascript:localStorage.setItem('requestNumber', '\(ConnectToolBlack.requestNumber)');", completionHandler: nil)
        webView.evaluateJavaScript("javascript:localStorage.setItem('redirect_uri', '\(ConnectToolBlack.redirect_uri)');", completionHandler: nil)
        webView.evaluateJavaScript("javascript:localStorage.setItem('referralCode', '\(ConnectToolBlack.referralCode)');", completionHandler: nil)
        webView.evaluateJavaScript("javascript:localStorage.setItem('notifyUrl', '\(ConnectToolBlack.notifyUrl)');", completionHandler: nil)
         
        // 輸入測試 code
//        let Input_Email = ""
//        let Input_Password = ""
//        let testJS = "javascript:(function(){document.getElementById('Input_Email').value = '\(Input_Email)';})();" + "javascript:(function(){document.getElementById('Input_Password').value = '" + Input_Password + "';})(); " + "javascript:(function(){document.getElementById('Input_ConfirmPassword').value = '" + Input_Password + "';})(); "
//        webView.evaluateJavaScript(testJS, completionHandler: nil)
        //************************************************************************
         
        // 設定遊戲註冊
        if (url.contains("/Account/Login")) {
            let AppRegisterUrl = "'/account/AppRegister/" + Tool.urlEncoded(ConnectToolBlack.Game_id) + "/" + Tool.urlEncoded(ConnectToolBlack.referralCode) + "?returnUrl=" + Tool.urlEncoded(ConnectToolBlack.redirect_uri) + "'";
            let script = "javascript:(function(){document.getElementById('goToRegister').href=" + AppRegisterUrl + ";})()";
            
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}


@available(iOS 13.0, *)
extension WebViewController:  WKScriptMessageHandler {
    
    // **************** JavascriptInterface **************************
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
         
        if(message.name == "callbackHandler"){
            //************************************************************************
        }
        
        if(message.name == "locationHref"){
            //頁面跳轉
        }
        
        if(message.name == "sendFinish"){
            //關閉頁面
            finishWebPage();
        }
        
        if(message.name == "iOS17dame"){
            //************************************************************************
            // 驗證儲存
//            print("驗證儲存")
//            webView.evaluateJavaScript("localStorage.getItem(\"requestNumber\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
//            webView.evaluateJavaScript("localStorage.getItem(\"access_token\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
//            webView.evaluateJavaScript("localStorage.getItem(\"RSAstr\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
//            webView.evaluateJavaScript("localStorage.getItem(\"Secret\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
//            webView.evaluateJavaScript("localStorage.getItem(\"ClientID\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
//            webView.evaluateJavaScript("localStorage.getItem(\"me\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
//            webView.evaluateJavaScript("localStorage.getItem(\"access_token\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
//            webView.evaluateJavaScript("localStorage.getItem(\"redirect_uri\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
//            webView.evaluateJavaScript("localStorage.getItem(\"referralCode\")") { (value, error) in
//                 print(value)
//                print(error)
//             }
            //************************************************************************
        }
        
        
        /**
         * 註冊結束
         */
        if(message.name == "CompleteRegistration"){
//            let backTypeResponse = ["accountBackType":"Register"];
//            NotificationCenter.default.post(name: NSNotification.Name.r17dame_ReceiverCallback,object: nil, userInfo:backTypeResponse as [AnyHashable : Any])
            // finishWebPage();
            WebViewOpenAuthorizeURL();
        }
        
        if(message.name == "CompleteLogin"){
//            let backTypeResponse = ["accountBackType":"Login"];
//            NotificationCenter.default.post(name: NSNotification.Name.r17dame_ReceiverCallback,object: nil, userInfo:backTypeResponse as [AnyHashable : Any])
//            finishWebPage();
            WebViewOpenAuthorizeURL();
        }
        
        
        // 消費
        if(message.name == "appLinkDataCallBack_CompleteConsumeSP"){
             
            do {
                let _messageString = message.body as! String
                let data = _messageString.data(using: .utf8)!
                
                let decoder = JSONDecoder()
                let _CreateSPCoinResponse = try decoder.decode(CreateSPCoinResponse.self, from:data)
   
                let backTypeResponse = [
                    "accountBackType":"CompleteConsumeSP",
                    "CompleteConsumeSP":_CreateSPCoinResponse,
                    "consume_transactionId":_CreateSPCoinResponse.data.transactionId,
                    "consume_status":_CreateSPCoinResponse.data.orderStatus,
                    "transactionId":_CreateSPCoinResponse.data.transactionId,
                    "orderNo":_CreateSPCoinResponse.data.orderNo,
                    "productName":_CreateSPCoinResponse.data.productName,
                    "spCoin":_CreateSPCoinResponse.data.spCoin,
                    "rebate":_CreateSPCoinResponse.data.rebate,
                    "orderStatus":_CreateSPCoinResponse.data.orderStatus,
                    "state":_CreateSPCoinResponse.data.state,
                    "notifyUrl":_CreateSPCoinResponse.data.notifyUrl,
                ] as [String : Any];
                NotificationCenter.default.post(name: NSNotification.Name.r17dame_ReceiverCallback,object: nil, userInfo:backTypeResponse as [AnyHashable : Any])
                finishWebPage();
            } catch {
                //print(error)
            }
        }
         
        // 購買
        if(message.name == "appLinkDataCallBack_CompletePurchase"){
            
            let PurchaseMessage    = message.body
            let fullPurchaseArr = (PurchaseMessage as AnyObject).components(separatedBy: ",")
            
            let state = fullPurchaseArr[0]
            let TradeNo = fullPurchaseArr[1]
            let PurchaseOrderId = fullPurchaseArr[2]
            
            let backTypeResponse = [
                "accountBackType":"CompletePurchase",
                "state":state,
                "TradeNo":TradeNo,
                "PurchaseOrderId":PurchaseOrderId,
            ]
            
            NotificationCenter.default.post(name: NSNotification.Name.r17dame_ReceiverCallback,object: nil, userInfo:backTypeResponse as [AnyHashable : Any])
            finishWebPage();
        } 
    }
    
   private func WebViewOpenAuthorizeURL() {
       let _state = UUID().uuidString
       //轉 OpenAuthorizeURL
       var components = URLComponents()
       components.scheme = "https"
       components.host = APIClient.host
       components.path = "/connect/Authorize"
       components.queryItems = [
           URLQueryItem(name: "response_type", value: "code"),
           URLQueryItem(name: "client_id", value: ConnectToolBlack.ClientID),
           URLQueryItem(name: "redirect_uri", value: ConnectToolBlack.redirect_uri),
           URLQueryItem(name: "scope", value: "game+offline_access"),
           URLQueryItem(name: "state", value: _state)
       ]
       
       openURLPage(url: components.url!)
    }
}


extension Notification.Name {
    static var r17dame_ReceiverCallback: Notification.Name {
        return .init(rawValue: "com.r17dame.CONNECT_ACTION.ReceiverCallback") }
}

extension URL {
    var components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}

extension Array where Iterator.Element == URLQueryItem {
    subscript(_ key: String) -> String? {
        return first(where: { $0.name == key })?.value
    }
}
