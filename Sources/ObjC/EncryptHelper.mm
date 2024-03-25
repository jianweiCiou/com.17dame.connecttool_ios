//
//  EncryptHelper.m
//  
//
//  Created by Jianwei Ciou on 2024/3/18.
//

#import "EncryptHelper.h"
#include "BasicEncrypt.h"

@implementation EncryptHelper

+(instancetype) sharedHelper {
    static EncryptHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}
 
//-(NSString*) encrypt:(NSString*)message {
//    //get std::string from NSString
//    string cppMessage = string([message UTF8String]);
//    //run the encrypt function in C++ class normally
//    string encryptedMessage = BasicEncHelper::encrypt(cppMessage);
//    //get NSString from std::string
//    const char* encryptedMessageInC = encryptedMessage.c_str();
//    return [NSString stringWithCString:encryptedMessageInC              encoding:NSUTF8StringEncoding];
//}


//-(NSString *)decrypt:(NSString *)message {
//    return nil;
//}


//-(NSObject*) getxSignature:(NSString*) RSAstr :(NSString*) signdata{
//
//    //
//    //char * getxSignature(std::string RSAstr ,std::string signdata);
//
//    string cppRSAstr = string([RSAstr UTF8String]);
//    string cppSigndata = string([signdata UTF8String]);
//
//    //run the encrypt function in C++ class normally
//    string encryptedMessage = BasicEncHelper::getxSignature(cppRSAstr,cppSigndata);
//
//    //get NSString from std::string
//    const char* encryptedMessageInC = encryptedMessage.c_str();
//    return [NSString stringWithCString:encryptedMessageInC              encoding:NSUTF8StringEncoding];
//}


@end
