//
//  Header.h
//  
//
//  Created by Jianwei Ciou on 2023/12/19.
//

#pragma once
 
#ifndef CTool_h
#define CTool_h
 
#endif /* Header_h */
 

#import <Foundation/Foundation.h>
 

//#import <UIKit/UIKit.h>


#include <stdio.h>
 
 

NS_ASSUME_NONNULL_BEGIN
 
@interface APIClient_objc : NSObject
{ 
}
+(NSString *)host;
+(NSString *)game_api_host; 

+ (void)setHost:(NSString *)newValue;
+ (void)setGame_api_host:(NSString *)newValue;
 
+(void)getConnectToken:(NSString *)_toolVS
                      :(NSString *)code
                      :(NSString *)client_id
                      :(NSString *)client_secret
                      :(NSString *)redirect_uri
                      :(NSString *)grant_type; 

+(void)getHostClient:(NSString *)_toolVS;
+(void)getGame_api_hostClient:(NSString *)_toolVS;
 
@end

NS_ASSUME_NONNULL_END
