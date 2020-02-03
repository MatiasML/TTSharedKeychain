//
//  ViewController.swift
//  TTSharedKeychain
//
//  Created by matiasspinelli4 on 02/03/2020.
//  Copyright (c) 2020 matiasspinelli4. All rights reserved.
//

import UIKit
import TTSharedKeychain

class ViewController: UIViewController, TTSharedKeychainProtocol {
    
    func showAlertFailure() {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()


        let sharedKeychain = TTSharedKeychainManager(delegate: self)
        
        // guardo MI numero de version
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let appVersionKey = "ExampleVersion"
            sharedKeychain.save(string: appVersion, forKey: appVersionKey)
//            TTSharedKeychainManager.shared.save(string: appVersion, forKey: appVersionKey)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

