//
//  EncryptHelper.h
//  
//
//  Created by Jianwei Ciou on 2024/3/18.
//


#import <Foundation/Foundation.h>
@interface EncryptHelper : NSObject
@property (nonatomic, strong) NSString *key;
+(instancetype) sharedHelper; 
@end
