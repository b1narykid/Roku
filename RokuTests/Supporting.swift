//
//  Supporting.swift
//  Evenus
//
// Copyright (c) 2015 Ivan Trubach
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Swift
import XCTest
import CoreData
@testable import Roku

extension XCTestCase {
    public override func performTest(run: XCTestRun) {
        if Data.tests.failed && !self.continueAfterFailure  {
            self.continueAfterFailure = false
        }
        
        super.performTest(run)
    }
}

// MARK: CoreData && Roku

public class User: NSManagedObject {
    @NSManaged public var address:     String?
    
    @NSManaged public var firstName:   String
    @NSManaged public var lastName:    String
    @NSManaged public var dateOfBirth: NSDate
}

/// Create test attribute for `NSEntityDescription`.
internal func createAttr(name: String, _ attrType: NSAttributeType, _ opt: Bool, _ idx: Bool) -> NSAttributeDescription {
    let attrDescr = NSAttributeDescription()
    attrDescr.name = name
    attrDescr.attributeType = attrType
    attrDescr.optional = opt
    attrDescr.indexed = idx
    return attrDescr
}

public class Data {
    internal var failed: Bool = false
    
    public internal(set) lazy var managedObjectModel: NSManagedObjectModel = {
        // Prepare single-entity managed object model
        let managedObjectModel = NSManagedObjectModel()
        // Prepare entity
        let entity = NSEntityDescription()
        entity.name = "User"
        entity.managedObjectClassName = "\(User.self)"
        // Create attributes
        let firstName   = createAttr("firstName",   .StringAttributeType, false, true)
        let lastName    = createAttr("lastName",    .StringAttributeType, false, true)
        let address     = createAttr("address",     .StringAttributeType, true,  true)
        let dateOfBitrh = createAttr("dateOfBitrh", .DateAttributeType,   false, true)
        // Set attributes
        entity.properties = [firstName, lastName, address, dateOfBitrh]
        // Set entities
        managedObjectModel.entities = [entity]
        // Done
        return managedObjectModel
    }()
    
    public internal(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch {
            let error = error as NSError
            print(error)
            XCTFail("Failed to create storage model with error: \(error).")
            self.failed = true
        }
        
        return psc
    }()
    
    public internal(set) lazy var storageModel: StorageModel = {
        let psc = { self.persistentStoreCoordinator }
        return StorageModel(persistentStoreCoordinator: psc)
    }()
}

internal extension Data {
    internal static let tests = Data()
}
