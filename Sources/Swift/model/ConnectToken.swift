//
//  File.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/13.
//

import Foundation

public struct ConnectToken  {
    public let access_token: String
    public let token_type: String
    public let expires_in: Int
    public let refresh_token: String
}
extension ConnectToken: Codable { }
