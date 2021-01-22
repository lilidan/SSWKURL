//
//  ViewController.m
//  SSWKURLDemo
//
//  Created by sgcy on 2020/5/11.
//  Copyright © 2020 sgcy. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "SSWKURL.h"

@interface ViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>

@property (nonatomic,strong) NSDictionary *timing;
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) NSDate *beginDate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional se3tup after loading the view.
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"event"];
    
    
    NSString *jScript = @"window.webkit.messageHandlers.event.postMessage({\"\":\"\"});";
    WKUserScript *js = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [config.userContentController addUserScript:js];
    
    [config ssRegisterURLProtocol:[SSWKURLProtocol class]];
    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    wkWebView.navigationDelegate = self;
    [self.view addSubview:wkWebView];
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://v.youku.com/v_show/id_XNDc1NDI5MzQ0OA==.html"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.bilibili.com/video/BV1rf4y1e7MD?p=2"]];

//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.iqiyi.com/v_1pxfxfkiehg.html?vfrm=pcw_home&vfrmblk=D&vfrmrst=712211_focus_A_image4"]];

    
    [wkWebView loadRequest:request];
    
    self.webView = wkWebView;
    self.beginDate = [NSDate date];
}



- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDate *nowDate = [NSDate date];
    NSTimeInterval delta = [nowDate timeIntervalSinceDate:self.beginDate];
    if (delta > 0.5) {
        NSLog(@"%f",delta);
        NSLog(@"--------------");
    }
     
//    [self.webView evaluateJavaScript:@"JSON.stringify(window.performance.timing.toJSON())" completionHandler:^(NSString * _Nullable timingStr, NSError * _Nullable error) {
//           if (!error) {、
//               self.timing = [NSJSONSerialization JSONObjectWithData:[timingStr dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:nil];
//               NSInteger before =  [self.timing[@"domainLookupStart"] integerValue] - [self.timing[@"navigationStart"] integerValue];
//               NSInteger dnsTime =  [self.timing[@"domainLookupEnd"] integerValue] - [self.timing[@"domainLookupStart"] integerValue];
//               NSInteger handShakeTime =  [self.timing[@"connectEnd"] integerValue] - [self.timing[@"connectStart"] integerValue];
//
//               NSInteger requestTime =  [self.timing[@"responseStart"] integerValue] - [self.timing[@"requestStart"] integerValue];
//               NSInteger responseTime =  [self.timing[@"responseEnd"] integerValue] - [self.timing[@"responseStart"] integerValue];
//               NSInteger domTime =  [self.timing[@"domComplete"] integerValue] - [self.timing[@"responseEnd"] integerValue];
//
//               NSLog(@"BEFORE %d",before);
//               NSLog(@"DNS %d",dnsTime);
//               NSLog(@"TCP %d",handShakeTime);
//               NSLog(@"REQUEST %d",requestTime);
//               NSLog(@"RESPONSE %d",responseTime);
//               NSLog(@"DOM %d",domTime);
//
//
//           }
//       }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
   NSLog(@"");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"");
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"");

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"");

}




@end
