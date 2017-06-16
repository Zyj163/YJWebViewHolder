//
//  YJWebViewHolder.swift
//  YJWebViewController
//
//  Created by ddn on 2017/6/13.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit
import WebKit

enum YJWebViewKeyPath: String {
	case none
	case loading
	case title
	case estimatedProgress
}

@objc protocol YJWebViewHolderDelegate: NSObjectProtocol {
	@objc optional func didReceive(_ webView: WKWebView, message: WKScriptMessage)
	@objc optional func decidePolicy(_ webView: WKWebView, forNavigationAction action: WKNavigationAction, handler: (WKNavigationActionPolicy)->Void)
	@objc optional func didStartLoad(_ webView: WKWebView)
	@objc optional func didFinishLoad(_ webView: WKWebView, error: Error?)
	@objc optional func didChanged(_ webView: WKWebView, keyPath: String, value: Any?)
}

final class YJWebViewHolder: NSObject {
	
	fileprivate let config: WKWebViewConfiguration = WKWebViewConfiguration()
	
	fileprivate var webView: YJWebView!
	
	var webV: UIView {
		get {
			return webView
		}
	}
	
	fileprivate var progressView: UIProgressView = UIProgressView(progressViewStyle: .default)
	
	var progressV: UIView {
		get {
			return progressView
		}
	}
	
	fileprivate weak var owner: YJWebViewHolderDelegate!
	
	fileprivate override init() {
		super.init()
	}
	
	deinit {
		self.webView.removeObserver(self, forKeyPath: YJWebViewKeyPath.loading.rawValue)
		self.webView.removeObserver(self, forKeyPath: YJWebViewKeyPath.title.rawValue)
		self.webView.removeObserver(self, forKeyPath: YJWebViewKeyPath.estimatedProgress.rawValue)
	}
}

extension YJWebViewHolder {
	
	convenience init<T: UIViewController>(_ owner: T, configHandler: ((WKWebViewConfiguration)->[String]?)? = nil) where T: YJWebViewHolderDelegate {
		self.init()
		self.owner = owner
		
		let messages = configHandler?(config)
		messages?.forEach{config.userContentController.add(self, name: $0)}
		
		webView = YJWebView(frame: owner.view.bounds, configuration: config)
		webView.navigationDelegate = self
		webView.uiDelegate = self
		webView.allowsBackForwardNavigationGestures = true
		webView.messages = messages
		
		webView.addObserver(self, forKeyPath: YJWebViewKeyPath.loading.rawValue, options: .new, context: nil)
		webView.addObserver(self, forKeyPath: YJWebViewKeyPath.title.rawValue, options: .new, context: nil)
		webView.addObserver(self, forKeyPath: YJWebViewKeyPath.estimatedProgress.rawValue, options: .new, context: nil)
	}
	
	func loadURL(_ urlStr: String) {
		
		guard let url = URL(string: urlStr) else { return }
		
		let request = URLRequest(url: url)
		
		self.webView.load(request)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		guard let keyPath = keyPath else { return }
		
		let path = YJWebViewKeyPath(rawValue: keyPath)
		if path != .none {
			let value = change?[.newKey]
			owner.didChanged?(webView, keyPath: keyPath, value: value)
			if path == .estimatedProgress {
				progressView.progress = value as! Float
			} else if path == .loading {
				progressView.isHidden = !(value as! Bool)
			}
		}
	}
	
	func dropMessages(_ messages: [String]) {
		messages.forEach { config.userContentController.removeScriptMessageHandler(forName: $0) }
	}
}

extension YJWebViewHolder: WKNavigationDelegate {
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if owner.responds(to: #selector(YJWebViewHolderDelegate.decidePolicy(_:forNavigationAction:handler:))) {
			owner.decidePolicy!(webView, forNavigationAction: navigationAction, handler: decisionHandler)
		} else {
			decisionHandler(.allow)
		}
	}
	
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		owner.didStartLoad?(webView)
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		owner.didFinishLoad?(webView, error: nil)
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		owner.didFinishLoad?(webView, error: error)
	}
}

extension YJWebViewHolder: WKUIDelegate {
	func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
		YJEasyAlert.show(from: owner as! UIViewController)
	}
	
	func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
		YJEasyAlert.show(message, actions: [
			{ () -> (String?, UIAlertActionStyle, ((UIAlertAction) -> ())?) in
				return ("取消", .cancel, {(_)->() in
					completionHandler(false)
				})
			},
			{ () -> (String?, UIAlertActionStyle, ((UIAlertAction) -> ())?) in
				return ("确认", .default, {(_)->() in
					completionHandler(true)
				})
			}
		], from: owner as! UIViewController)
	}
}

extension YJWebViewHolder: WKScriptMessageHandler {
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		owner.didReceive?(webView, message: message)
	}
}

extension WKWebViewConfiguration {
	private func jsObjFromString(jsStr: String, injectionTime: WKUserScriptInjectionTime = .atDocumentEnd, mainOnly: Bool = true) -> WKUserScript {
		return WKUserScript(source: jsStr, injectionTime: injectionTime, forMainFrameOnly: mainOnly)
	}
	
	private func jsObjFromFile(filePath: String) -> WKUserScript? {
		guard FileManager.default.fileExists(atPath: filePath) else { return nil }
		guard let jsStr = try? String(contentsOfFile: filePath, encoding: .utf8) else { return nil }
		return jsObjFromString(jsStr: jsStr)
	}
	
	func addJs(_ js: String) {
		let script = jsObjFromString(jsStr: js)
		userContentController.addUserScript(script)
	}
	
	func addJsFromFile(_ filePath: String) -> Bool {
		guard let script = jsObjFromFile(filePath: filePath) else { return false }
		userContentController.addUserScript(script)
		return true
	}
}


fileprivate class YJWebView: WKWebView {
	
	var messages: [String]?
	
	override func removeFromSuperview() {
		super.removeFromSuperview()
		
		messages?.forEach { (message) in
			configuration.userContentController.removeScriptMessageHandler(forName: message)
		}
		
	}
}






















