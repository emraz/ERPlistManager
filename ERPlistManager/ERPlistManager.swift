//
//  ERPlistManager.swift
//  ERPlistManager
//
//  Created by Mahmudul Hasan on 5/20/21.
//

import UIKit

class ERPlistManager: NSObject {
    
    class func isExistPlist(_ name: String) -> Bool {
        
        var isExist = false
        
        //Get the documents directory path
        let path = self.getDocumentsDirectoryPathforFile(name)
        let fileManager = FileManager.default
        
        //To check in Documents folder
        isExist = fileManager.fileExists(atPath: path)
        if !isExist {
            //To check in main bundle
            let fileName = name.components(separatedBy: ".")[0]
            if Bundle.main.path(forResource: fileName, ofType: "plist") != nil {
                isExist = true
            }
        }
        
        return isExist
    }
    
    class func copyPListFromBundleToDocumentsDirectory(_ name: String, _ destFolder: String) -> (Bool, String) {
                
        var isSuccess = false
        var message = ""
        
        //Get the documents directory path
        let subDir = (destFolder.isEmpty) ? name : "\(destFolder)/\(name)"

        let destPath = self.getDocumentsDirectoryPathforFile(subDir)
        let fileManager = FileManager.default
        print(destPath)
        
        //To check in Documents folder
        if !fileManager.fileExists(atPath: destPath) {
            //To check in main bundle
            let fileName = name.components(separatedBy: ".")[0]
            if let sPath =  Bundle.main.path(forResource: fileName, ofType: "plist") {
                
                do {
                    try FileManager.default.copyItem(atPath: sPath, toPath: destPath)
                    isSuccess = true
                    message = "Plist copied successfully"
                    
                } catch {
                    isSuccess = false
                    message = "Error: unable to copy plist: \(error)"
                }
                return (isSuccess, message)
            }
            else {
                isSuccess = false
                message = "Plist not found in Main Bundle"
            }
        }
        else {
            isSuccess = false
            message = "Plist Already Exist"
        }
        
        return (isSuccess, message)
    }
    
    class func getPListPath(byName name: String) -> String {
        
        var isExist = false

        var path = self.getDocumentsDirectoryPathforFile(name)
        let fileManager = FileManager.default
        
        //To check in Documents folder
        isExist = fileManager.fileExists(atPath: path)
        if !isExist {
            //To check in main bundle
            let fileName = name.components(separatedBy: ".")[0]
            if let pPath =  Bundle.main.path(forResource: fileName, ofType: "plist") {
                isExist = true
                path = pPath
            }
        }
        
        return path
    }
    
    class func getPListURL(byName name: String) -> URL {
        
        let pPath = self.getDocumentsDirectoryPathforFile(name)
        let fileManager = FileManager.default
        var url = URL(fileURLWithPath: pPath)
        
        if !fileManager.fileExists(atPath: pPath) {
            
            let fileName = name.components(separatedBy: ".")[0]
            url = Bundle.main.url(forResource: fileName, withExtension: "plist")!
        }

        return url
    }
    
    class func readDataDictionary(fromPlistPath path: String?) -> [AnyHashable : Any]? {
        
        return NSDictionary(contentsOfFile: path ?? "") as Dictionary?
    }
    
    class func readDataArray(fromPlistPath path: String?) -> [AnyHashable]? {
        
        return NSArray(contentsOfFile: path ?? "") as? [AnyHashable]
    }
    
    class func readPlist(byName name: String) -> [AnyObject] {
        
        let plistURL = getPListURL(byName: name)
        let plistData = try! Data(contentsOf: plistURL)
        let plistProperty = try! PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)
        return plistProperty as! [AnyObject]
    }
    
    class func writeData(intoExisitngPlist name: String, newDataDictionary dataDict: [AnyHashable : Any]) {
        
        let documentsPath = self.getDocumentsDirectoryPathforFile(name)
        
        var savedValue: [AnyHashable : Any] = [:]
        
        if FileManager.default.fileExists(atPath: documentsPath) {
            if let dictionary = NSDictionary(contentsOfFile: documentsPath) as Dictionary? {
                savedValue = dictionary
            }
        } else {
            let fileName = name.components(separatedBy: ".")[0]
            let bundlePath = Bundle.main.path(forResource: fileName, ofType: "plist")
            if let dictionary = NSDictionary(contentsOfFile: bundlePath ?? "") as Dictionary? {
                savedValue = dictionary
            }
        }
        
        for (k, v) in dataDict { savedValue[k] = v }
        let success = (savedValue as NSDictionary).write(toFile: documentsPath, atomically: true)
        print("Success = \(success)")
    }
    
    class func writeAnyObjectData(intoExisitngPlist name: String, objectData: [AnyObject])-> Bool {
        
        let documentsPath = self.getDocumentsDirectoryPathforFile(name)
        let success = (objectData as AnyObject).write(toFile: documentsPath, atomically: true)
        return success
    }
    
    private class func getDocumentsDirectoryPathforFile(_ name: String) -> String {

        let documentsDirectory = FileManager.documentsDir()
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(name).path
        return path
    }
}

extension FileManager {
    class func documentsDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

