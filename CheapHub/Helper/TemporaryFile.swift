//
//  TemporaryFile.swift
//  CheapHub
//
//  Created by GK on 2018/9/7.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Foundation

struct TemporaryFile {
    let directoryURL: URL
    let fileURL: URL
    
    let deleteDirectory: () throws -> Void
    
    init(creatingTemDirectoryForFilename fileName: String) throws {
        let (directory, deleteDirectory) = try FileManager.default.urlForUniqueTemporaryDirectory()
        self.directoryURL = directory
        self.fileURL = directory.appendingPathComponent(fileName)
        self.deleteDirectory = deleteDirectory
    }
}

extension FileManager {
    //用fileName创建一个唯一的临时路径,返回路径的URL
    
    func urlForUniqueTemporaryDirectory(preferredName: String? = nil) throws -> (url: URL, deleteDirectory: () throws -> Void ){
        let basename = preferredName ?? UUID().uuidString
        
        var counter = 0
        var createdSubdirectory: URL? = nil
        
        repeat {
            do {
                let subdirName = counter == 0 ? basename: "\(basename)-(counter)"
                let subdirectory = temporaryDirectory.appendingPathComponent(subdirName, isDirectory: true)
                try createDirectory(at: subdirectory, withIntermediateDirectories: false, attributes: nil)
                createdSubdirectory = subdirectory
            } catch CocoaError.fileWriteFileExists {
                //Catch the file exists error, try another name
                //其他的错误将跑出给调用者
                counter += 1
            }
        } while createdSubdirectory == nil
        
        let directory = createdSubdirectory!
        let deleteDirectory: () throws -> Void = {
            try self.removeItem(at: directory)
        }
        return (directory, deleteDirectory)
    }
}
