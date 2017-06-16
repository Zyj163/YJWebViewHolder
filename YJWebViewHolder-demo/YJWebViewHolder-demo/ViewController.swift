//
//  ViewController.swift
//  YJWebViewHolder-demo
//
//  Created by 张永俊 on 2017/6/16.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    lazy var webViewHolder: YJWebViewHolder = YJWebViewHolder(self) { (config: WKWebViewConfiguration) -> [String]? in
        
        config.addJs("document.getElementById('index-kw').value = 'test'")
        
        let re = config.addJsFromFile(Bundle.main.path(forResource: "fetchMenus.js", ofType: nil)!)
        
        return re ? ["didFetchMenus"] : nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webViewHolder.webV)
        view.addSubview(webViewHolder.progressV)
        webViewHolder.loadURL("http://www.baidu.com")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webViewHolder.webV.frame = view.bounds
        webViewHolder.progressV.frame = CGRect(x: 0, y: topLayoutGuide.length, width: view.bounds.width, height: 3)
    }
}

extension ViewController: YJWebViewHolderDelegate {
    func didReceive(_ webView: WKWebView, message: WKScriptMessage) {
        if message.name == "didFetchMenus" {
            print(message.body)
        }
    }
}

