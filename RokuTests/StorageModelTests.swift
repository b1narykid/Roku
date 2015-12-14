//
//  StorageModelTests.swift
//  RokuTests
//
//  Created by Ivan Trubach on 15.11.15.
//  Copyright © 2015 Ivan Trubach. All rights reserved.
//

import XCTest
@testable import Roku

public class StorageModelTests: XCTestCase {
//    public override func setUp() {
//        super.setUp()
//    }
//    
//    public override func tearDown() {
//        super.tearDown()
//    }
    
    /// Test model creation (no null objects etc.).
    public func testModelCreatedSuccessfully() {
        // Assert not NullObject
        let err1 = "Persistent store should be initialized correctly."
        let err2 = "Managed object model should be initialized correctly."
        XCTAssertFalse(Data.tests.storageModel.persistentStoreCoordinator is NullObject, err1)
        XCTAssertFalse(Data.tests.storageModel.managedObjectModel         is NullObject, err2)
        // Assert equal data
        let err3 = "StorageModel's managed object model should be equal to model stored in test case."
        let err4 = "StorageModel's persistent store coordinator's managed object model should be equal to model stored in test case."
        XCTAssertTrue(Data.tests.storageModel.managedObjectModel                            === Data.tests.managedObjectModel, err3)
        XCTAssertTrue(Data.tests.storageModel.persistentStoreCoordinator.managedObjectModel === Data.tests.managedObjectModel, err4)
    }
    
    public func testModelReset() {
        let pscBackup = Data.tests.storageModel.persistentStoreCoordinator
        let pscEmpty  = NSPersistentStoreCoordinator(managedObjectModel: pscBackup.managedObjectModel)
        Data.tests.storageModel.resetModelWith(persistentStoreCoordinator: pscEmpty, lazyEvaluation: true)
        
        XCTAssertNil(Data.tests.storageModel._model)
        XCTAssertNil(Data.tests.storageModel._store)
        
        Data.tests.storageModel.resetModelWith(persistentStoreCoordinator: pscBackup, lazyEvaluation: false)
    }
    
//    public func testPerformanceExample() {
//        self.measureBlock { }
//    }
}
