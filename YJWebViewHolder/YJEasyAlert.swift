//
//  YJEasyAlert.swift
//  YJWebViewController
//
//  Created by ddn on 2017/6/13.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit

public struct YJEasyAlertOptions : OptionSet {
    
    public typealias RawValue = UInt
    
    public var rawValue: YJEasyAlertOptions.RawValue
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static var confirm: YJEasyAlertOptions {
        return YJEasyAlertOptions(rawValue: 0x01)
    }
    
    public static var cancel: YJEasyAlertOptions {
        return YJEasyAlertOptions(rawValue: 0x02)
    }
}

public class YJEasyAlert {
    
	/// alert
	///
	/// - Parameters:
	///   - title: title
	///   - message: message
	///   - actions: 闭包数组，每个闭包的返回值是(String?, UIAlertActionStyle, ((UIAlertAction) -> ())?)，其中第一个参数是按钮文字，第二个参数是按钮style，第三个是按钮触发的动作（闭包）
	///   - from: 从那个控制器modal
    /// - Example: 
    /**
     YJEasyAlert.show(message, actions:
     [
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
     */
	public class func show(from: UIViewController, withTitle title: String? = nil, message: String? = nil, actions: [()->(String?, UIAlertActionStyle, ((UIAlertAction)->())?)]? = nil) {
		
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
    
    public class func show(from: UIViewController, withTitle title: String? = nil, message: String? = nil, options: YJEasyAlertOptions = [.confirm, .cancel], action: ((YJEasyAlertOptions)->())?) {
        
        var actions = [()->(String?, UIAlertActionStyle, ((UIAlertAction)->())?)]()
        if options.contains(.confirm) {
            actions.append({ () -> (String?, UIAlertActionStyle, ((UIAlertAction) -> ())?) in
                return ("确认", .default, { (_)->() in
                    action?(.confirm)
                })
            })
        }
        if options.contains(.cancel) {
            actions.append({ () -> (String?, UIAlertActionStyle, ((UIAlertAction) -> ())?) in
                return ("确认", .default, { (_)->() in
                    action?(.cancel)
                })
            })
        }
        show(from: from, withTitle: title, message: message, actions: actions)
    }
}


















