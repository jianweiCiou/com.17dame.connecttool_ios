//
//  Created by Jianwei Ciou on 2024/3/15.
//

import Foundation
import Security

@available(iOS 13.0, *)
class Tool  { 
     
    /// URL 編碼
    /// - Parameters:
    ///   - string: 內容
    public static func urlEncoded(_ string: String) -> String {
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: "!*'\"();:@&=+$,/?%#[]% ")
        return string.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? string
    }
    
    /// 儲存最後的時間到期日
    /// - Parameters:
    ///   - tokenData_expires_in: 取 access token
    public static func saveExpiresTs(tokenData_expires_in:Int)   {
        var  expires_in =  Float(tokenData_expires_in)
        expires_in = expires_in * 0.9
        let currentTs =  NSDate().timeIntervalSince1970 / 1000
        let currentTssString = "\(currentTs)"
        let currentTsDouble = Float(currentTssString)!
        let expiresTs = currentTsDouble + expires_in
        let expiresTsString = "\(expiresTs)"
        
        Configuration.value(value: expiresTsString, forKey:"expiresTs")
    }
    
    /// 移除 AccessToken
    public static func RemoveAccessToken() {
        Configuration.value(value: "", forKey:"expiresTs")
        Configuration.value(value: "", forKey:"access_token")
        Configuration.value(value: "", forKey:"refresh_token")
    }
     
    /// 取時間格式
    public static func getTimestamp() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        return  dateString + "Z";
    }
    
    static func encrypt(string: String, publicKey: String?) -> String? {
        guard let publicKey = publicKey else {
            return nil
        }
        
        let keyString = publicKey.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----\n", with: "").replacingOccurrences(of: "\n-----END PUBLIC KEY-----", with: "")
        guard let data = Data(base64Encoded: keyString) else {
            return nil
        }
        
        var attributes: CFDictionary {
            return [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                   kSecAttrKeyClass: kSecAttrKeyClassPublic,
              kSecAttrKeySizeInBits: 2048,
            kSecReturnPersistentRef: kCFBooleanTrue] as CFDictionary
        }
        
        var error: Unmanaged<CFError>? = nil
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            return nil
        }
        return vEncrypt(string: string, publicKey: secKey)
    }
    
    static func vEncrypt(string: String, publicKey: SecKey) -> String? {
        let buffer = [UInt8](string.utf8)
        
        var keySize = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)
         
        guard SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else {
            return nil
        }
        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }
}
