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
    
    var delegate: UIViewController?
    
    public init(delegate: UIViewController?) {
        self.delegate = delegate
    }

    public init() {
        
    }
    
    // MARK: - Public
    // MARK: - Save
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
    
    // MARK: - Get
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
    
    // MARK: - Delete
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
    
    
    // MARK: - SOME LOGIC
    public func sendCrossLink(appName: String, minVersion: String) {
        
        var deeplinkString = ""
        var versionString = ""
        
        if appName == "ThreeKeychain" {
            deeplinkString = "com.mepa://"
            versionString = "\(appName)Version"
        }
        
        if appName == "TwoKeychain" {
            deeplinkString = "com.meli://"
            versionString = "\(appName)Version"
        }
        
        self.deleteKey(keyValue: "deeplinkString")

        if let appURL = URL(string: deeplinkString) {            
            let canOpen = UIApplication.shared.canOpenURL(appURL)
            print("Can open \"\(appURL)\": \(canOpen)")
            // si no puede abrir, guarda el deeplink
            if !canOpen {
                self.save(string: deeplinkString, forKey: "deeplinkString")
                self.showAlert(title: "No se puede abrir \(appName)", message: "Se guardo el deeplink en AppGroups")
            }
            else {
                // si lo puede abrir pregunta, valida el numero de version
                if let threeKeychainVersion = self.getStringKey(keyValue: versionString) {
                    if threeKeychainVersion >= minVersion {
                        self.showAlert(title: "Se abre mediante DEEPLINK", message: "")
                        // si tiene el min de version, manda el deeplink
                        UIApplication.shared.open(appURL)
                    } else {
                        // si no tiene el min de version, guarda el deeplink
                        self.save(string: deeplinkString, forKey: "deeplinkString")
                        self.showAlert(title: "No cumple con el minimo de version de \(appName)", message: "Se guardo el deeplink en AppGroups")
                    }
                } else {
                    // esto puede suceder si cuenta con una version vieja que no guardo el numero de version de MPEA o simplemente al querer guardarlo, falló.
                    self.save(string: deeplinkString, forKey: "deeplinkString")
                    self.showAlert(title: "No tenemos guardado el numero de version de \(appName)", message: "Se guardo el deeplink en AppGroups")
                }
            }
        }
    }
    
    public func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        delegate?.present(alert, animated: true, completion: nil)
    }
        
    // MARK: - TTSharedKeychainProtocol
    public func showAlertFailure() {
        let alert = UIAlertController(title: "No se puede abrir MEPA", message: "Se guardo el deeplink en AppGroups", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        delegate?.present(alert, animated: true, completion: nil)
    }
}
