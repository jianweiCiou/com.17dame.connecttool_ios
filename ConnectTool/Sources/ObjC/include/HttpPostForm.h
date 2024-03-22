#import <Foundation/Foundation.h>

@interface HttpPostForm:NSObject
-(id)initWithUrl:(NSString *)urlString;

@property(nonatomic) NSMutableURLRequest *request;
@property(nonatomic) NSString *urlString;
@property(nonatomic) NSMutableDictionary *headers;
@property(nonatomic) NSMutableDictionary *fields;
 
-(void)addHeader:(NSString *)key value:(NSString *)value;
 
-(void)addFormField:(NSString *)key value:(NSString *)value;
 
- (void)finish:(void(^)(NSData *, NSURLResponse *, NSError *))callback;

@end
