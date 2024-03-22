//
//  RSAEncryption.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/15.
//
import Foundation
import Security

struct RSAEncryption {
  var publicKey: SecKey!
  
  init(publicKeyString: String) throws {
    self.publicKey = try makePublicKey(from: publicKeyString)
  }
  
  func makePublicKey(from keyString: String) throws -> SecKey {
    let pubKeyData = Data(base64Encoded: sanitize(key: keyString))!
    
    let query: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
      kSecAttrKeySizeInBits as String: 2048
    ]
    
    var unmanagedError: Unmanaged<CFError>?
    
    guard let pubKeyRef = SecKeyCreateWithData(pubKeyData as CFData, query as CFDictionary, &unmanagedError) else {
      throw unmanagedError!.takeRetainedValue() as Error
    }
    
    return pubKeyRef
  }
  
  func encrypt(value: String) throws -> String {
    let valueData = value.data(using: .utf8)!
    
    let bufferSize = SecKeyGetBlockSize(publicKey) - 11
    let buffers = makeBuffers(fromData: valueData, bufferSize: bufferSize)
    
    var encryptedData = Data()
    
    for buffer in buffers {
      var encryptionError: Unmanaged<CFError>?
      
      guard let encryptedBuffer = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, buffer as CFData, &encryptionError) as Data? else {
        throw encryptionError!.takeRetainedValue() as Error
      }
      
      encryptedData.append(encryptedBuffer)
    }
    
    return encryptedData.base64EncodedString()
  }
  
  func makeBuffers(fromData data: Data, bufferSize: Int) -> [Data] {
    guard data.count > bufferSize else {
      return [data]
    }
    
    var buffers: [Data] = []
    
    for i in 0..<bufferSize {
      let start = i * bufferSize
      
      let lengthOffset = start + bufferSize
      let length = lengthOffset < data.count ? bufferSize : data.count - start
      
      let bufferRange = Range<Data.Index>(NSMakeRange(start, length))!
      buffers.append(data.subdata(in: bufferRange))
    }
    
    return buffers
  }
  
  private func sanitize(key: String) -> String {
    let headerRange = key.range(of: "-----BEGIN PUBLIC KEY-----")
    let footerRange = key.range(of: "-----END PUBLIC KEY-----")
    
    var sanitizedKey = key
    
    if let headerRange = headerRange, let footerRange = footerRange {
      let keyRange = Range<String.Index>(uncheckedBounds: (lower: headerRange.upperBound, upper: footerRange.lowerBound))
      sanitizedKey = String(key[keyRange])
    }
    
    return sanitizedKey
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: "\n")
      .joined()
  }
}
