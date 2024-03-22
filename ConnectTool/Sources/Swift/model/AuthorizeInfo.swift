//
//  AuthorizeInfo.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/15.
//

import Foundation

public struct AuthorizeInfo  {
    public let meInfo: MeInfo
    public let connectToken: ConnectToken
    public let state: String
    public let access_token: String
}
extension AuthorizeInfo: Codable { }
 
