//
//  APIClient.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/15.
//

import Foundation

@available(iOS 13.0, *)
class APIClient{
    public static var host = "gamar18portal.azurewebsites.net"
    public static var game_api_host = "r18gameapi.azurewebsites.net"
    
    public static func getConnectToken(
        _connectToolBlack:ConnectToolBlack,
        connectBasic:ConnectBasic,
        _code:String,
        redirect_uri:String,
        connectTokenCall: @escaping (ConnectToken) -> Void ) {
             
            guard let url = URL(string: "https://\(APIClient.host)/connect/token") else {
                return
            }
            
            let redirect_uri_Encoded = Tool.urlEncoded(redirect_uri)
            let client_secret_Encoded = Tool.urlEncoded(connectBasic.client_secret)
            let data : Data = "code=\(_code)&client_id=\(connectBasic.client_id)&client_secret=\(client_secret_Encoded)&redirect_uri=\(redirect_uri_Encoded)&grant_type=authorization_code".data(using: .utf8)!
            
            var request : URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
            request.setValue(NSLocalizedString("lang", comment: ""), forHTTPHeaderField:"Accept-Language");
            request.httpBody = data
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            // vs let session = URLSession.shared
            // make the request
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                
                
                DispatchQueue.main.async { // Correct
                    
                    guard let responseData = data else {
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let _ConnectToken = try decoder.decode(ConnectToken.self, from: responseData)
                        connectTokenCall(_ConnectToken)
                    } catch {
                        print(error)
                    }
                }
            })
            task.resume()
            
        }
    
    public static func getMe(
        _connectToolBlack:ConnectToolBlack,
        X_Developer_Id:String,
        RequestNumber:String,
        GameId:String,
        ReferralCode:String,
        callbackMeInfo: @escaping (MeInfo) -> Void ) {
            
            do {
                let timestamp = Tool.getTimestamp();
                
                let signdata = "?RequestNumber=\(Tool.urlEncoded(RequestNumber))&Timestamp=\(timestamp)&GameId=\(Tool.urlEncoded(ConnectToolBlack.Game_id))&ReferralCode=\(Tool.urlEncoded(ConnectToolBlack.referralCode))";
                 
                let X_Signature = try APIClient.signature(string:signdata,RSAstr:ConnectToolBlack.RSAstr)
                  
                let access_token = Configuration.value(defaultValue: "", forKey: "access_token")
                let authorization = "Bearer " + access_token;
                
                guard let url = URL(string: "https://\(APIClient.game_api_host)/api/Me" + signdata) else {
                    return
                }
                
                var request : URLRequest = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Content-Type: application/json", forHTTPHeaderField:"Content-Type");
                request.setValue(authorization, forHTTPHeaderField:"Authorization");
                request.setValue(_connectToolBlack.connectBasic.X_Developer_Id, forHTTPHeaderField:"X-Developer-Id");
                request.setValue(X_Signature, forHTTPHeaderField:"X-Signature");
                
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                let task = session.dataTask(with: request, completionHandler: {
                    (data, response, error) in
                    DispatchQueue.main.async { // Correct
                        guard let responseData = data else {
                            return
                        }
                        do {
                            let decoder = JSONDecoder()
                            let _meInfo = try decoder.decode(MeInfo.self, from: responseData)
                            
                            let jsonData = try JSONEncoder().encode(_meInfo)
                            let jsonString = String(data: jsonData, encoding: .utf8)!
                            
                            print(jsonString)
                            
                            Configuration.value(value: jsonString, forKey: "me")
                            
                            callbackMeInfo(_meInfo)
                        } catch {
                            print(error)
                        }
                    }
                })
                task.resume()
            } catch {
                //print(error)
            }
        }
    
    public static func signature(string: String,RSAstr: String) throws -> String? {
        
        let derString = RSAstr
            .replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let derData = Data(base64Encoded: derString, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        let attributes: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits: 2048
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(derData as CFData, attributes as CFDictionary, &error) else {
            throw error!.takeUnretainedValue()
        }
         
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, .rsaSignatureMessagePKCS1v15SHA256) else {
            return nil
        }
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, Data(string.utf8) as CFData, &error) else {
            throw error!.takeUnretainedValue()
        }
        return (signature as Data).base64EncodedString()
    }
    
    public static func getRefreshTokenData(
        _connectToolBlack:ConnectToolBlack,
        connectBasic:ConnectBasic,
        refresh_token:String,
        redirect_uri:String,
        connectTokenCall: @escaping (ConnectToken) -> Void ) {
             
            guard let url = URL(string: "https://\(APIClient.host)/connect/token") else {
                return
            }
            
            let redirect_uri_Encoded = Tool.urlEncoded(redirect_uri)
            let client_secret_Encoded = Tool.urlEncoded(connectBasic.client_secret)
            let data : Data = "refresh_token=\(refresh_token)&client_id=\(connectBasic.client_id)&client_secret=\(client_secret_Encoded)&redirect_uri=\(redirect_uri_Encoded)&grant_type=authorization_code".data(using: .utf8)!
            
            var request : URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
            request.setValue(NSLocalizedString("lang", comment: ""), forHTTPHeaderField:"Accept-Language");
            request.httpBody = data
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            // make the request
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                 
                DispatchQueue.main.async {
                    guard let responseData = data else {
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let _ConnectToken = try decoder.decode(ConnectToken.self, from: responseData)
                         
                        connectTokenCall(_ConnectToken)
                    } catch {
                        //print(error)
                    }
                }
            })
            task.resume() 
        }
}
