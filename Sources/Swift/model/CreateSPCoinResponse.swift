//
//  CreateSPCoinResponse.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/20.
//

import Foundation

public struct CreateSPCoinResponse {
    public let data: PaymentData
    public let status: Int
    let message: String?
    let detailMessage: String?
    public let requestNumber: String?
}
public struct PaymentData  {
    public let transactionId : String
    public let orderNo: String
    public let productName: String 
    public let spCoin: Int
    public let rebate: Int
    public let orderStatus: String
    public let state: String
    public let notifyUrl: String
}

extension CreateSPCoinResponse: Codable { }

extension PaymentData: Codable { }
