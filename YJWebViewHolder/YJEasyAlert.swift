//
//  YJEasyAlert.swift
//  YJWebViewController
//
//  Created by ddn on 2017/6/13.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit

class YJEasyAlert {
	class func show(_ title: String? = nil, message: String? = nil, actions: [()->(String?, UIAlertActionStyle, ((UIAlertAction)->())?)]? = nil, from: UIViewController) {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		actions?.forEach { (actionGenerator) in
			let (actionTitle, actionStyle, action) = actionGenerator()
			let a = UIAlertAction(title: actionTitle, style: actionStyle, handler: action)
			alert.addAction(a)
		}
		
		if actions?.count == 0 {
			let a = UIAlertAction(title: "确定", style: .default, handler: nil)
			alert.addAction(a)
		}
		
		from.present(alert, animated: true, completion: nil)
	}
}
