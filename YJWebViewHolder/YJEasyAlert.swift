//
//  YJEasyAlert.swift
//  YJWebViewController
//
//  Created by ddn on 2017/6/13.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit

public enum YJEasyAlertAction {
    
    case ack(String?, UIAlertActionStyle?, (() -> Void)?)
    case cancel(String?, UIAlertActionStyle?, (() -> Void)?)
    case delete(String?, UIAlertActionStyle?, (() -> Void)?)
    
    case easyAck((() -> Void)?)
    case easyCancel((() -> Void)?)
    case easyDelete((() -> Void)?)
    
    var text: String {
        switch self {
        case .ack(let text, _, _):
            return text ?? "确认"
        case .cancel(let text, _, _):
            return text ?? "取消"
        case .delete(let text, _, _):
            return text ?? "删除"
        case .easyAck:
            return "确认"
        case .easyCancel:
            return "取消"
        case .easyDelete:
            return "删除"
        }
    }
    
    var action: (() -> Void)? {
        switch self {
        case .ack(_, _, let a), .cancel(_, _, let a), .delete(_, _, let a), .easyAck(let a), .easyCancel(let a), .easyDelete(let a):
            return a
        }
    }
    
    var style: UIAlertActionStyle {
        switch self {
        case .ack(_, let style, _):
            return style ?? .default
        case .cancel(_, let style, _):
            return style ?? .cancel
        case .delete(_, let style, _):
            return style ?? .destructive
        case .easyAck:
            return .default
        case .easyCancel:
            return .cancel
        case .easyDelete:
            return .destructive
        }
    }
}

public class YJEasyAlert {
    
	/// 警告框
	///
    /// - Parameters:
    ///   - from: 从哪个控制器modal
	///   - title: title
	///   - message: message
    ///   - actions: 闭包数组，每个闭包的返回值是(String?, UIAlertActionStyle, (() -> ())?)，其中第一个参数是按钮文字，第二个参数是按钮style，第三个是按钮触发的动作（闭包）
    ///   - inputs: 配置输入框
    /// - Example: 
    /**
     YJEasyAlert.show(message, actions:
     [
        { () -> (String?, UIAlertActionStyle, (() -> ())?) in
            return ("取消", .cancel, {})
        },
        { () -> (String?, UIAlertActionStyle, (() -> ())?) in
            return ("确认", .default, {})
        }
     ], from: vc)
     */
    @discardableResult
    public class func alert(from: UIViewController, withTitle title: String? = nil, message: String? = nil, actions: [()->(String?, UIAlertActionStyle, (()->())?)]? = nil, inputs: [((UITextField)->Void)?]? = nil) -> UIAlertController {
        
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		return alertController(alert, from: from, withTitle: title, message: message, actions: actions, inputs: inputs)
	}
    
    @discardableResult
    public class func actionSheet(from: UIViewController, withTitle title: String? = nil, message: String? = nil, actions: [()->(String?, UIAlertActionStyle, (()->())?)]? = nil, inputs: [((UITextField)->Void)?]? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        return alertController(alert, from: from, withTitle: title, message: message, actions: actions, inputs: inputs)
    }
    
    /// 警告框
    ///
    /// - Parameters:
    ///   - from: 从哪个控制器modal
    ///   - title: title
    ///   - message: message
    ///   - actions: [YJEasyAlertAction]，默认是一个没有动作的确认键
    ///   - inputs: 配置输入框
    @discardableResult
    public class func easyAlert(from: UIViewController, withTitle title: String? = nil, message: String? = nil, actions: [YJEasyAlertAction] = [.easyAck(nil)], inputs: [((UITextField)->Void)?]? = nil) -> UIAlertController {
        
        let actions = generateActions(actions)
        return alert(from: from, withTitle: title, message: message, actions: actions, inputs: inputs)
    }
    
    @discardableResult
    public class func easyActionSheet(from: UIViewController, withTitle title: String? = nil, message: String? = nil, actions: [YJEasyAlertAction] = [.easyAck(nil)], inputs: [((UITextField)->Void)?]? = nil) -> UIAlertController {
        
        let actions = generateActions(actions)
        return actionSheet(from: from, withTitle: title, message: message, actions: actions, inputs: inputs)
    }
    
    fileprivate class func generateActions(_ actions: [YJEasyAlertAction])->[()->(String?, UIAlertActionStyle, (()->())?)]? {
        return actions.map { (action: YJEasyAlertAction) -> ()->(String?, UIAlertActionStyle, (()->())?) in
            switch action {
            case let .ack(text, style, act), let .cancel(text, style, act), let .delete(text, style, act):
                return {(text, style ?? action.style, act ?? action.action)}
            case let .easyAck(act), let .easyCancel(act), let .easyDelete(act):
                return {(action.text, action.style, act ?? action.action)}
            }
        }
    }
    
    fileprivate class func alertController(_ alert: UIAlertController, from: UIViewController, withTitle title: String? = nil, message: String? = nil, actions: [()->(String?, UIAlertActionStyle, (()->())?)]? = nil, inputs: [((UITextField)->Void)?]? = nil) -> UIAlertController {
        
        actions?.forEach { (actionGenerator) in
            let (actionTitle, actionStyle, action) = actionGenerator()
            var handler: ((UIAlertAction)->Void)?
            if let action = action {
                handler = { (_)->Void in
                    action()
                }
            }
            let a = UIAlertAction(title: actionTitle, style: actionStyle, handler: handler)
            alert.addAction(a)
        }
        
        if actions?.count == 0 {
            let a = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(a)
        }
        
        inputs?.forEach {alert.addTextField(configurationHandler: $0)}
        
        from.present(alert, animated: true, completion: nil)
        
        return alert
    }
}
