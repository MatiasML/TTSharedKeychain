//
//  ViewController.swift
//  TTSharedKeychain
//
//  Created by matiasspinelli4 on 02/03/2020.
//  Copyright (c) 2020 matiasspinelli4. All rights reserved.
//

import UIKit
import TTSharedKeychain

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendAction(_ sender: Any) {
        let sharedKeychain = TTSharedKeychainManager()
        sharedKeychain.sendCrossLink(appName: "ThreeKeychain", minVersion: "2.0")
    }
}

