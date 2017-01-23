//
//  DeepLink.swift
//  Pods
//
//  Created by 臧金晓 on 23/01/2017.
//
//

import Foundation

public protocol URLHandlerContext {
    func complete()
    func progress(_ value: Double)
    func error(error: String)
}

public protocol URLWrapper {
    var path: String { get }
    var host: String? { get }
    var scheme: String? { get }
    func queryValuesFor(name: String) -> [String]
}

extension UIViewController {
    var topViewController: UIViewController {
        if let vc = presentedViewController {
            return vc.topViewController
        } else {
            return self
        }
    }
    
    var topNavigationController: UINavigationController? {
        return topViewController._topNavigationController
    }
    
    var _topNavigationController: UINavigationController? {
        return nil
    }
}

extension UINavigationController {
    override var _topNavigationController: UINavigationController? {
        return self
    }
}

extension UITabBarController {
    override var _topNavigationController: UINavigationController? {
        return selectedViewController?._topNavigationController
    }
}

extension URLWrapper {
    public var topViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.topViewController
    }
    
    public var topNavigationController: UINavigationController? {
        return UIApplication.shared.keyWindow?.rootViewController?.topNavigationController
    }
}

public protocol URLHandler {
    func canHandle(url: URLWrapper) -> Bool
    func handle(url: URLWrapper, context: URLHandlerContext)
}


//class is faster than struct?
fileprivate class AnyURLWrapper: URLWrapper {
    init(_ url: URL) {
        self.url = url
    }
    
    let url: URL
    lazy var components: URLComponents? = self.createComponents()
    private func createComponents() -> URLComponents? {
        return URLComponents(url: url, resolvingAgainstBaseURL: false)
    }
    
    fileprivate var path: String {
        return url.path
    }
    
    fileprivate var host: String? {
        return url.host
    }
    
    fileprivate var scheme: String? {
        return url.scheme
    }
    
    fileprivate func queryValuesFor(name: String) -> [String] {
        return components?.queryItems?.filter { $0.name == name }.map { $0.value ?? "" } ?? []
    }
}

fileprivate class AnyURLHandlerContext: URLHandlerContext {
    let completeBlock: (() -> Void)?
    let progressBlock: ((Double) -> Void)?
    let errorBlock: ((String) -> Void)?
    
    var completed = false
    
    init(completeBlock: (() -> Void)?, progressBlock: ((Double) -> Void)?, errorBlock: ((String) -> Void)?) {
        self.completeBlock = completeBlock
        self.progressBlock = progressBlock
        self.errorBlock = errorBlock
    }
    
    fileprivate func complete() {
        objc_sync_enter(self)
        if !completed {
            completed = true
            completeBlock?()
        }
        objc_sync_exit(self)
    }
    
    deinit {
        complete()
    }
    
    fileprivate func progress(_ value: Double) {
        progressBlock?(value)
    }
    
    fileprivate func error(error: String) {
        errorBlock?(error)
    }
}

public class RouteManager {
    private var handlers: [URLHandler] = []
    public static let `default` = RouteManager()
    
    init() {
        
    }
    
    public func register(handler: URLHandler) {
        objc_sync_enter(self)
        handlers.append(handler)
        objc_sync_enter(self)
    }
    
    @discardableResult public func handle(_ url: URL, complete: (() -> Void)? = nil, error: ((String) -> Void)? = nil, progress: ((Double) -> Void)? = nil) -> Bool {
        let urlWrapper = AnyURLWrapper(url)
        var handler: URLHandler?
        objc_sync_enter(self)
        for (_, item) in handlers.enumerated() {
            if item.canHandle(url: urlWrapper) {
                handler = item
            }
        }
        objc_sync_exit(self)
        
        if let handler = handler {
            handler.handle(url: urlWrapper, context: AnyURLHandlerContext(completeBlock: complete, progressBlock: progress, errorBlock: error))
            return true
        } else {
            return false
        }
    }
}





