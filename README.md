
# SSWKURL

Intercept and cache requests of WKWebView.

介绍[iOS完美请求拦截](https://www.jianshu.com/p/7b28cbd8f92a)
[WKWebView缓存+请求拦截](https://www.jianshu.com/p/44f4fa1d3d12)

## Features

- Intercept All Requests of WKWebView.
- Cache requests.

## Perfomance

TestPage: 
https://www.bilibili.com/video/BV1rf4y1e7MD?p=2

Almost same with the cache in webview.But now we can control it without restriction.

![image.png](https://upload-images.jianshu.io/upload_images/611240-5e603c89a084b986.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



## Installation

Drag the `SSWKURL.h` and `SSWKURL.m` files into your project.


## Usage

Subclass `SSWKURLProtocol` like `NSURLProtol`.

Implement your own `-startLoading:` and `-stopLoading`.

Then call `[yourWKURLConfiguration ssRegisterURLProtocol:[YourSSWKURLProtocol class]];`

Then You could moniter requests or load cache for requests.

## Compare to VasSonic

- support WKWebview
- iOS SDK > 12


## Blog

[WKWebView完美(?)网络请求拦截](https://www.jianshu.com/p/7b28cbd8f92a)
[WKWebView缓存+请求拦截](https://www.jianshu.com/p/44f4fa1d3d12)

