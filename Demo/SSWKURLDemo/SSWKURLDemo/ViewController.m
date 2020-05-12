//
//  ViewController.m
//  SSWKURLDemo
//
//  Created by sgcy on 2020/5/11.
//  Copyright © 2020 sgcy. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "TPWKURLProtocol.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config ssRegisterURLProtocol:[TPWKURLProtocol class]];
    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:wkWebView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.163.com"]];
    [wkWebView loadRequest:request];
}


@end
