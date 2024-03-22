#import "HttpPostForm.h"

@implementation HttpPostForm

-(id)initWithUrl:(NSString *)urlString{
  self.request = [[NSMutableURLRequest alloc]init];
  self.urlString = urlString;
  self.headers = [[NSMutableDictionary alloc]init];
  self.fields = [[NSMutableDictionary alloc]init];
  return self;
}

-(void)addHeader:(NSString *)key value:(NSString *)value{
  [self.headers setObject:value forKey:key];
}

-(void)addFormField:(NSString *)key value:(NSString *)value{
  [self.fields setObject:value forKey:key];
}

- (void)finish:(void (^)(NSData *, NSURLResponse *, NSError *))callback{
  NSURL *url = [[NSURL alloc]initWithString:self.urlString];
  [self.request setURL:url];
  [self.request setHTTPMethod:@"POST"];
  // 添加请求头
  for (NSString *key in self.headers){
    NSString *value = self.headers[key];
    [self.request setValue:value forHTTPHeaderField:key];
  }
  // 添加请求头 Content-Type
  [self.request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  // 添加请求参数
  NSMutableData *body = [NSMutableData data];
  for (NSString *key in self.fields){
    NSString *value = self.fields[key];
    [body appendData:[[NSString stringWithFormat:@"%@=%@", key, value] dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  if ([body length] > 0) {
    [self.request setHTTPBody:body];
    // 添加请求头 content-length
    NSString *postLength = [NSString stringWithFormat:@"%ld", [body length]];
    [self.request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  }
  
  void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
    if (callback) {
      callback(data, response, error);
    }
  };
  
  [[[NSURLSession sharedSession] dataTaskWithRequest:self.request completionHandler:completionHandler] resume];
}

@end
