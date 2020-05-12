
# SSWKURL

Intercept Requests of WKWebView.

## Features

- Intercept All Requests of WKWebView.


## Installation

Drag the `SSWKURL.h` and `SSWKURL.m` files into your project.


## Usage

Subclass `SSWKURLProtocol` like `NSURLProtol`.

Implement your own `-startLoading:` and `-stopLoading`.

Then call `[yourWKURLConfiguration ssRegisterURLProtocol:[YourSSWKURLProtocol class]];`

Then You could moniter requests or load cache for requests.

## Blog

[WKWebView完美(?)网络请求拦截](https://www.jianshu.com/p/7b28cbd8f92a)
