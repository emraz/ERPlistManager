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
        var path = self.getDocumentsDirectoryPathforFile(name)
        let fileManager = FileManager.default
        
        //To check in Documents folder
        isExist = fileManager.fileExists(atPath: path)
        if !isExist {
            //To check in main bundle
            let fileName = name.components(separatedBy: ".")[0]
            path = Bundle.main.path(forResource: fileName, ofType: "plist") ?? ""
            
            if(path.count > 0) {
                isExist = true
            }
        }
        
        return isExist
    }
    
    class func createPListwithName(_ name: String) {
        
        //Crete file in documents directory
        //Get the documents directory path
        let documentsDirectory = FileManager.documentsDir()
        
        var path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(name).path
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path) {
            path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(name).path
        }
        
        var data: [AnyHashable : Any]?
        
        if fileManager.fileExists(atPath: path) {
            data = NSDictionary(contentsOfFile: path) as Dictionary?
        } else {
            // If the file doesn’t exist, create an empty dictionary
            data = [:]
        }
        (data as NSDictionary?)?.write(toFile: path, atomically: true)
    }
    
    class func getPListPath(byName name: String) -> String {
        
        var pPath = self.getDocumentsDirectoryPathforFile(name)
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: pPath) {
            
            let fileName = name.components(separatedBy: ".")[0]
            
            pPath = Bundle.main.path(forResource: fileName, ofType: "plist") ?? ""
        }
        
        return pPath
    }
    
    class func readDataDictionary(fromPlistPath path: String?) -> [AnyHashable : Any]? {
        
        return NSDictionary(contentsOfFile: path ?? "") as Dictionary?
    }
    
    class func readDataArray(fromPlistPath path: String?) -> [AnyHashable]? {
        
        return NSArray(contentsOfFile: path ?? "") as? [AnyHashable]
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
    
    class func getDocumentsDirectoryPathforFile(_ name: String) -> String {
        //Get the documents directory path
        let documentsDirectory = FileManager.documentsDir() //FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        //let documentsDirectory = paths[0]
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
