//
//  Tool.m
//  
//
//  Created by Jianwei Ciou on 2023/12/19.
//
//#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "APIClient_objc.h"
#import "HttpPostForm.h"
 
 
#include <cxxLibrary.h>

@implementation APIClient_objc

static NSString *_host = @"https://gamar18portal.azurewebsites.net";
+ (NSString *)host { return _host; }
static NSString *_game_api_host= @"https://r18gameapi.azurewebsites.net";
+ (NSString *)game_api_host { return _game_api_host; }


+ (void)setHost:(NSString *)newValue {
    _host = newValue;
}
+ (void)setGame_api_host:(NSString *)newValue {
    _game_api_host = newValue;
}
+ (void)getHostClient:(NSString *)_toolVS{
    
}
+ (void)getGame_api_hostClient:(NSString *)_toolVS{
    
}


+(void)getConnectToken:(NSString *)_toolVS
                      :(NSString *)code
                      :(NSString *)client_id
                      :(NSString *)client_secret
                      :(NSString *)redirect_uri
                      :(NSString *)grant_type{ 
}
@end
//@end

