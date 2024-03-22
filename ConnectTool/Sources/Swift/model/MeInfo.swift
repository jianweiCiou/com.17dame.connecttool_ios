//
//  MeInfo.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/15.
//

import Foundation

public struct MeInfo {
    let message: String?
    let detailMessage: String?
    let status: Int
    public let requestNumber: String
    public let data: MeData
}

public struct MeData  {
    public let userId : String
    public let email: String
    public let nickName: String?
    public let avatarUrl: String?
    public let spCoin: Int
    public let rebate: Int
}
extension MeInfo: Codable { }

extension MeData: Codable { }
