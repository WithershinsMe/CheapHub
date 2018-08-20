//
//  LoginViewController.swift
//  CheapHub
//
//  Created by GK on 2018/8/16.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit
import WebKit
import Moya

class LoginViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
        
        Network.Manager.networkDelegate = self
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, context: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            
        }
    }
}
extension LoginViewController: NetworkProtocol {
    func networkActivityBegin(_ targetType: TargetType) {
          indicator.startAnimating()
    }
    
    func networkActivityEnd(_ targetType: TargetType) {
         indicator.stopAnimating()
    }
}
extension LoginViewController: WKNavigationDelegate {
    //URL请求之前询问
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if let path = webView.url?.path, path.contains("callback") {
            if let query = webView.url?.query {
                loginTokenActionWithQueryString(query)
            }
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    //开始下载URL内容之前回调
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    //URL下载完毕之后询问，可以根据服务端返回的内容在做一次确定
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        indicator.stopAnimating()
        decisionHandler(.allow)
    }
    //载入下载的内容
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
    }
    
    
    //流程发生错误回调
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error: error as NSError)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error: error as NSError)
    }
    
    //掌控定制的scheme URL
    func handleError(error: NSError) {
        if let failingUrl = error.userInfo["NSErrorFailingURLStringKey"] as? String {
            if let url = URL(string: failingUrl) {
                let didOpen = UIApplication.shared.canOpenURL(url)
                if didOpen {
                    print("openURL succeeded")
                    return
                }
            }
        }
    }
    //在收到服务器重定向消息并且跳转询问允许之后回调改方法
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
   
    //进程方法回调
    // WKWebView跨进程，WKView进程退出时，会回调该方法(概率性回调,iOS9和iOS9之后)
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        
    }
    
    //HTTPS证书自定义 (概率性回调)
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//
//    }
    
}

extension LoginViewController: WKUIDelegate {
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//
//    }
    
    //WKWebView关闭时的回调
    func webViewDidClose(_ webView: WKWebView) {
        
    }
    //alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Swift.Void) {
        
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Swift.Void) {
        
    }
    
    @available(iOS 10, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return true
    }
    
    @available(iOS 10, *)
    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        return nil
    }
    @available(iOS 10, *)
    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        
    }
    
}
extension LoginViewController {
    
    private func loginTokenActionWithQueryString(_ query: String) {
        guard let queryDict = parseURLQuery(query) else {
            print("Authorization code error, please check Authorization process ")
            return
        }
        
        guard let code = queryDict["code"],let state = queryDict["state"]else {
            print("Authorization code error")
            return
        }
        
        AuthAPI.manager.getOauthAccessToken(code, state) { [weak self] result in
            switch result {
            case .success(let token):
                UserDefaults.standard.set(token, forKey: UserDefaults.Keys.accessToken)
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                self?.showAlert(error.rawValue, alertHandle: { _ in
                    
                })
            }
        }
    }
    private func parseURLQuery(_ query: String) -> [String: String]? {
        guard !query.isEmpty else {
            return nil
        }
        var queryDiction = [String:String]()
        
        let querys = query.components(separatedBy: "&")
        for query in querys {
            let components = query.components(separatedBy: "=")
            if let key = components.first,let value = components.last {
                queryDiction[key] = value
            }
        }
        if queryDiction.isEmpty {
            return nil
        }
        return queryDiction
    }
}
//JS和Native之间的通信 WKWebView是异步的
//[wkWebView evaluateJavaScript:@"document.title"
//    completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
//    NSString *title = ret;
//    }];

// iOS7新增JavaScriptCore库，内部由JSContext对象，
//WKWebView,Web的window对象提供Webkit对象实现共享
//WKWebView绑定共享对象，通过特定的构造方法实现，通过指定 UserContentController 对象的 ScriptMessageHandler 经过 Configuration 参数构造时传入
/*
WKUserContentController *userContent = [[WKUserContentController alloc] init];
[userContent addScriptMessageHandler:id<WKScriptMessageHandler> name:@"MyNative"];

WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
config.userContentController = userContent;

WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
 */

//而 handler 对象需要实现指定协议，实现指定的协议方法，当 JS 端通过  window.webkit.messageHandlers 发送 Native 消息时，handler 对象的协议方法被调用，通过协议方法的相关参数传值
/*
 #pragma mark - WKScriptMessageHandler
 -  (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {}
 // Javascript
 function callNative() {
 window.webkit.messageHandlers.MyNative.postMessage('body');
 }
 
 JAVAScript调用
 // Javascript
 function callNative() {
 window.webkit.messageHandlers.MyNative.postMessage('body');
 }
 */


//内存结构

/*
 1  WKWebView比UIWebView内存小
    这是因为WKWebView是一个单独的进程，网页的载入和渲染这些耗内存和性能的过程都是在WKWebview进程中去实现的
 2  Web进程也是会崩溃的
    导致webview内存爆掉的页面同样也可能导致WKWebView内存爆掉，只不过这个上限值很高
 
 3  Cookie
    UIWebView通过NSHTTPCookieStorage来统一管理的，服务器返回是写入，发起请求时读取，web和native通过这个对象共享Cookie
    WKWebView不再是一个必经的流程节点，WKWebView同样会对改对象写入Cookie,担忧延迟，各个系统延迟也不，一样，发起请求也不会实时的去读取cookie,导致app重启cookie丢失，无法做到会话和native同步
 
    解决方法：
    WKWebView无法实时持久化Cookie，需要主动读取cookie写入磁盘，载入时在读取cookie
    登录之后保存cookie到磁盘，下次在webview初始化时读取本地的cookie
 
    一 通过WKWebView的标准接口实现cookie同步，有限制
 
    1  读取cookie写入NSHTTPCookieStorage
    Web请求分为三类： location跳转  AAJAX请求 资源载入
 
    location跳转会走webview组建Nativation代理，可以拦截响应回调
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
 {
 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
 id cookies = [httpResponse.allHeaderFields objectForKey:@“Set-Cookie”];
 if(cookies) {
 // Cookie 写入 NSHttpCookieStorage
 }
 decisionHandler(WKNavigationResponsePolicyAllow);
 }
 
    AJAX请求和资源载入不会走协议代理方法，如果是这两种登录方式是无法获取cookie的
 
   2  读取NSHTTPCookieStorage写入Request
    Request写入分两部分： 当前Request ,子元素Request
 
    当前Request写入： 设置request对象的header绑定cookie,只在当前请求中有效
    /****************
 NSURL *url = [NSURL URLWithString:@"https://www.hujiang.com"];
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
 [request addValue:@"key0=value0" forHTTPHeaderField:@"Cookie"];
 [wkWebView loadRequest:request];
 
    *****************/
    发起请求的reuqest通过IPC进程和webview通信，request的body在传递中被舍弃了，因此不能设定body值
 
  如果页面包括多个Frame,出现302重定向，cookie无法跨域设置，针对mainframe可以通过Delegate的请求询问方法手动载入cookie,其他frame没办法
 
  子资源request无法请求设置cookie
 
  二 私有方法
  UIWebView通过NSProtocol来拦截所有的HTTP和HTTPS网络请求，WKWebView默认不走改协议但可以通过私有方法来设置
 KWebView 包含一个 browsingContextController 属性对象，该对象提供了 registerSchemeForCustomProtocol 和 unregisterSchemeForCustomProtocol 两个方法，能通过注册 scheme 来代理同类请求，符合注册 scheme 类型的请求会走 NSURLProtocol 协议
 
  三 OAuth2
   WKWebView发起请求，服务端验证失败，返回重定向地址，app通过重定向地址，重新想服务端发起请求获取认证token,获取token后存储到本地，写入wKwebview的cookie,重新发起请求，服务器验证通过，进行后续服务
 
 
 WKWebView问题：
 1 进程崩溃
 WKWebView进程崩溃，app内效果就是白屏，解决方案是白屏是重新载入Request
 
 iOS9 delegate可以得到崩溃的回调，但如果占用内存过大不会回调
 iOS8下可以通过校验webview.title是否为空，title是WKwebview内置属性，自动读取doucment.title，在京城崩溃是为空
 WKWebView通过Scrollview来实现
 WKWebView的页面渲染与JS执行同步进行，在页面载入完成之后就获取innerHeight 或者 contentSize 都是不准确的，要么通过延迟获取，要么监听属性值变化，实时修正获取的值
 
 在 UIWebView 上，如果超链接设置未 tel://00-0000 之类的值，点击会直接拨打电话，但在 WKWebView 上，该点击没有反应，类似的都被屏蔽了，通过打开浏览器跳转 AppStore 已然无法实现
 这类情况只能在跳转询问中处理，校验 scheme 值通过 UIApplication 外部打开
 
 下载链接在 UIWebView 上其实也是需要特殊处理，在服务器响应询问中校验流类型即可
 
UIWebView 是通过 NSURLConneciton 处理的 HTTP 请求，而通过Conneciton 发出的请求都会遵循 NSURLProtocol 协议，通过这个特性，我们可以代理 Web 资源的下载，做统一的缓存管理或资源管理
 
 但在 WKWebView 上这个不可行了，因为 WKWebView 的载入在单独进程中进行，数据载入 app 无法干涉
 
 缓存问题：
 ios9 WKWebsiteDataStore管理缓存
 
 // RemoveCache
 NSSet *websiteTypes = [NSSet setWithArray:@[
 WKWebsiteDataTypeDiskCache,
 WKWebsiteDataTypeMemoryCache]];
 NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteTypes
 modifiedSince:date
 completionHandler:^{
 }];
 
 ios8下清理缓存
 而 iOS 9 之前，就只能通过删除文件来解决了，WKWebView 的缓存数据会存储在  ~/Library/Caches/BundleID/WebKit/ 目录下，可通过删除该目录来实现清理缓存
 
 https://juejin.im/entry/5975916e518825594d23d777
 */



