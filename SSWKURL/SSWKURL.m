//
//  SSWKURL.m
//  SSWKURL
//
//  Created by sgcy on 2020/4/21.
//  Copyright © 2020 sgcy. All rights reserved.
//

#import "SSWKURL.h"
#import <objc/runtime.h>

typedef BOOL (^HTTPDNSCookieFilter)(NSHTTPCookie *, NSURL *);


@interface NSURLRequest(requestId)

@property (nonatomic,assign) BOOL ss_stop;
- (NSString *)requestId;
- (NSString *)requestRepresent;

@end

static char *kNSURLRequestSSTOPKEY = "kNSURLRequestSSTOPKEY";

@implementation NSURLRequest(requestId)

- (BOOL)ss_stop
{
    return [objc_getAssociatedObject(self, kNSURLRequestSSTOPKEY) boolValue];
}

- (void)setSs_stop:(BOOL)ss_stop
{
    objc_setAssociatedObject(self, kNSURLRequestSSTOPKEY, @(ss_stop), OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)requestId
{
    return [@([self hash]) stringValue];
}

- (NSString *)requestRepresent
{
    return [NSString stringWithFormat:@"%@---%@",self.URL.absoluteString,self.HTTPMethod];
}

@end


@interface WKWebView(handlesURLScheme)


@end

@implementation WKWebView(handlesURLScheme)


+ (BOOL)handlesURLScheme:(NSString *)urlScheme
{
    return NO;
}

@end



@interface SSWKURLProtocol()

@property (nonatomic,readwrite,copy) NSURLRequest *request;

@end

@implementation SSWKURLProtocol


@end



@interface SSWKURLHandler:NSObject <WKURLSchemeHandler>

@property (nonatomic,strong) Class protocolClass;
@property (nonatomic,strong) NSURLSession *session;
//@property (nonatomic,strong) NSLock *lock;
@property (nonatomic,strong) dispatch_queue_t queue;

@end


@implementation SSWKURLHandler{
    HTTPDNSCookieFilter cookieFilter;
}

static SSWKURLHandler *sharedInstance = nil;

+ (SSWKURLHandler *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc]init];
        sharedInstance->cookieFilter = ^BOOL(NSHTTPCookie *cookie, NSURL *URL) {
            if ([URL.host containsString:cookie.domain]) {
                return YES;
            }
            return NO;
        };
    });
    return sharedInstance;
}



- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return _session;
}


- (dispatch_queue_t)queue
{
    if (!_queue) {
        _queue = dispatch_queue_create("SSWKURLHandler.queue", DISPATCH_QUEUE_SERIAL);
        _queue = dispatch_get_main_queue();
    }
    return _queue;
}

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
//    if (![self.protocolClass isKindOfClass:[SSWKURLProtocol class]]) {
//        @throw [NSException exceptionWithName:@"SSWKURLProtolRegisterFail" reason:@"URLProtocol is not subclass of SSWKURLProtol" userInfo:@{}];
//    }
    NSURLRequest *request = [urlSchemeTask request];
    NSMutableURLRequest *mutaRequest = [request mutableCopy];
    [mutaRequest setValue:[self getRequestCookieHeaderForURL:request.URL] forHTTPHeaderField:@"Cookie"];
    request = [mutaRequest copy];
    
    BOOL canInit = NO;
    if ([self.protocolClass respondsToSelector:@selector(canInitWithRequest:)]) {
        canInit = [self.protocolClass canInitWithRequest:urlSchemeTask.request];
    }
    if (canInit) {
        if ([self.protocolClass respondsToSelector:@selector(canonicalRequestForRequest:)]) {
            request = [self.protocolClass canonicalRequestForRequest:request];
            SSWKURLProtocol *obj = [[self.protocolClass alloc] init];
            obj.request = request;
            [obj startLoading:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(self.queue, ^{
                    if (urlSchemeTask.request.ss_stop == NO) {
                        if (error) {
                            [urlSchemeTask didReceiveResponse:response];
                            [urlSchemeTask didFailWithError:error];
                        }else{
                            [urlSchemeTask didReceiveResponse:response];
                            [urlSchemeTask didReceiveData:data];
                            [urlSchemeTask didFinish];
                            if ([response respondsToSelector:@selector(allHeaderFields)]) {
                                [self handleHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields] forURL:request.URL];
                            }
                        }
                    }
                });
            }];
        }
    }else{
        NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(self.queue, ^{
                if (urlSchemeTask.request.ss_stop == NO) {
                    if (error) {
                        [urlSchemeTask didReceiveResponse:response];
                        [urlSchemeTask didFailWithError:error];
                    }else{
                        [urlSchemeTask didReceiveResponse:response];
                        [urlSchemeTask didReceiveData:data];
                        [urlSchemeTask didFinish];
                        if ([response respondsToSelector:@selector(allHeaderFields)]) {
                            [self handleHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields] forURL:request.URL];
                        }
                    }
                }
            });
          
        }];
        [task resume];
    }
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
    dispatch_async(self.queue, ^{
        urlSchemeTask.request.ss_stop = YES;
    });
}


- (NSArray<NSHTTPCookie *> *)handleHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)URL {
    NSArray *cookieArray = [NSHTTPCookie cookiesWithResponseHeaderFields:headerFields forURL:URL];
    if (cookieArray != nil) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookieArray) {
            if (cookieFilter(cookie, URL)) {
                [cookieStorage setCookie:cookie];
            }
        }
    }
    return cookieArray;
}

- (NSString *)getRequestCookieHeaderForURL:(NSURL *)URL {
    NSArray *cookieArray = [self searchAppropriateCookies:URL];
    if (cookieArray != nil && cookieArray.count > 0) {
        NSDictionary *cookieDic = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
        if ([cookieDic objectForKey:@"Cookie"]) {
            return cookieDic[@"Cookie"];
        }
    }
    return nil;
}

- (NSArray *)searchAppropriateCookies:(NSURL *)URL {
    NSMutableArray *cookieArray = [NSMutableArray array];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        if (cookieFilter(cookie, URL)) {
            [cookieArray addObject:cookie];
        }
    }
    return cookieArray;
}


@end

@implementation WKWebViewConfiguration(ssRegisterURLProtocol)

- (void)ssRegisterURLProtocol:(Class)protocolClass
{
    SSWKURLHandler *handler = [SSWKURLHandler sharedInstance];
    handler.protocolClass = protocolClass;
    [self setURLSchemeHandler:handler forURLScheme:@"https"];
    [self setURLSchemeHandler:handler forURLScheme:@"http"];
}

@end
