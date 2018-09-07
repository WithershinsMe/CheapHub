//
//  TempFileDirectoryTest.swift
//  CheapHubTests
//
//  Created by GK on 2018/9/7.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit
import XCTest
@testable import CheapHub

class TempFileDirectoryTest: XCTestCase {
    func testTempFile() {
        var tmpDir: TemporaryFile
        do {
            tmpDir = try TemporaryFile(creatingTemDirectoryForFilename: "TestFile.txt")
            print(tmpDir.directoryURL.path)
            print(tmpDir.fileURL.path)
            assert(tmpDir != nil, "创建路径成功")
            try tmpDir.deleteDirectory()
            
        } catch {
            
        }
        
       
        
    }
}
