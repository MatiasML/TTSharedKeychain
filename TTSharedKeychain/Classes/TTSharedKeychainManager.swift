//
//  TTSharedKeychainManager.swift
//  TwoKeychain
//
//  Created by matias spinelli on 29/01/2020.
//  Copyright © 2020 matias spinelli. All rights reserved.
//

import UIKit

public protocol TTSharedKeychainProtocol {
    func showAlertFailure()
}

//let GROUP_NAME = "T9VUHG6RU2.com.mercadolibre"
let GROUP_NAME = "group.com.MatiasML"


public class TTSharedKeychainManager: TTSharedKeychainProtocol {

//    static let shared = TTSharedKeychainManager()
//    private init() { }
    
    var delegate: TTSharedKeychainProtocol
    
    public init(delegate: TTSharedKeychainProtocol) {
        self.delegate = delegate
//        super.init()
    }
    
    // MARK: - Public
    public func save(string: String, forKey keyValue: String) {
        
        guard let valueData = string.data(using: String.Encoding.utf8) else {
            print("Error saving text to Keychain")
            return
        }
        
        save(valueData: valueData, forKey: keyValue)
    }
    
    public func save(valueData: Data, forKey keyValue: String) {
        
        let queryAdd: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyValue as AnyObject,
            kSecValueData as String: valueData as AnyObject,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecAttrAccessGroup as String: GROUP_NAME as AnyObject
        ]
        
        let resultCode = SecItemAdd(queryAdd as CFDictionary, nil)
        
        if resultCode != noErr {
            print("Error saving to Keychain: \(resultCode)")
        }
    }
    
    
    public func getStringKey(keyValue: String) -> String? {

        let queryLoad: [String: AnyObject] = [
          kSecClass as String: kSecClassGenericPassword,
          kSecAttrAccount as String: keyValue as AnyObject,
          kSecReturnData as String: kCFBooleanTrue,
          kSecMatchLimit as String: kSecMatchLimitOne,
          kSecAttrAccessGroup as String: GROUP_NAME as AnyObject
        ]

        var result: AnyObject?

        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
          SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }

        if resultCodeLoad == noErr {
          if let result = result as? Data,
            let keyValue = NSString(data: result, encoding: String.Encoding.utf8.rawValue) as String? {
            return keyValue
          }
        } else {
          print("Error loading from Keychain: \(resultCodeLoad)")
        }
        return nil
    }
    
    public func getKey(keyValue: String) -> Data? {
           
           let queryLoad: [String: AnyObject] = [
             kSecClass as String: kSecClassGenericPassword,
             kSecAttrAccount as String: keyValue as AnyObject,
             kSecReturnData as String: kCFBooleanTrue,
             kSecMatchLimit as String: kSecMatchLimitOne,
             kSecAttrAccessGroup as String: GROUP_NAME as AnyObject
           ]

           var result: AnyObject?

           let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
             SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
           }

           if resultCodeLoad == noErr {
             if let result = result as? Data {
               return result
             }
           } else {
             print("Error loading from Keychain: \(resultCodeLoad)")
           }
        return nil
    }
    
    public func deleteKey(keyValue: String) {

        let queryDelete: [String: AnyObject] = [
          kSecClass as String: kSecClassGenericPassword,
          kSecAttrAccount as String: keyValue as AnyObject,
          kSecAttrAccessGroup as String: GROUP_NAME as AnyObject
        ]

        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)

        if resultCodeDelete != noErr {
          print("Error deleting from Keychain: \(resultCodeDelete)")
        }
    }
    
    // MARK: - TTSharedKeychainProtocol
    public func showAlertFailure() {
        
    }
}
