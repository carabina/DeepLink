//
//  ViewController.swift
//  DeepLink
//
//  Created by Tulipa on 01/23/2017.
//  Copyright (c) 2017 Tulipa. All rights reserved.
//

import UIKit
import DeepLink

struct A: URLHandler {
    func canHandle(url: URLWrapper) -> Bool {
        return true
    }
    
    func handle(url: URLWrapper, context: URLHandlerContext) {
        debugPrint("handle")
        debugPrint(url.queryValuesFor(name: "v").first ?? "")
        debugPrint(url.topNavigationController ?? "")
        debugPrint(url.topViewController ?? "")
        context.progress(1)
        context.complete()
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        RouteManager.default.register(handler: A())
        RouteManager.default.handle(URL(string: "http://www/aad/asdf/asdf?d=2&v=2")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

