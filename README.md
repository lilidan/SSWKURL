
# SSWKURL

Intercept Requests of WKWebView.

介绍[iOS完美请求拦截](https://www.jianshu.com/p/7b28cbd8f92a)

## Features

- Intercept All Requests of WKWebView.


## Installation

Drag the `SSWKURL.h` and `SSWKURL.m` files into your project.


## Usage

Subclass `SSWKURLProtocol` like `NSURLProtol`.

Implement your own `-startLoading:` and `-stopLoading`.

Then call `[yourWKURLConfiguration ssRegisterURLProtocol:[YourSSWKURLProtocol class]];`

Then You could moniter requests or load cache for requests.
