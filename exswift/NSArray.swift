//
//  NSArray.swift
//  ExSwift
//
//  Created by pNre on 10/06/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation

public extension NSArray {

    /**
        Converts an NSArray object to an OutType[] array containing the items in the NSArray of type OutType.
        
        - returns: Array of Swift objects
    */
//    func cast <OutType> () -> [OutType] {
//        var result = [OutType]()
//        
//        for item : AnyObject in self {
//            result += Ex.bridgeObjCObject(item) as [OutType]
//        }
//        
//        return result
//    }

    /**
        Flattens a multidimensional NSArray to an OutType[] array 
        containing the items in the NSArray that can be bridged from their ObjC type to OutType.
    
        - returns: Flattened array
    */
//    func flatten <OutType> () -> [OutType] {
//        var result = [OutType]()
////        let reflection = reflect(self)
//        
//        for i in 0..<reflection.count {
//            result += Ex.bridgeObjCObject(reflection[i].1.value) as [OutType]
//        }
//        
//        return result
//    }
    
    /**
        Flattens a multidimensional NSArray to a [AnyObject].
    
        - returns: Flattened array
    */
    func flattenAny () -> [AnyObject] {
        var result = [AnyObject]()
        
        for item in self {
            if let array = item as? NSArray {
                result += array.flattenAny()
            } else {
                result.append(item)
            }
        }
        
        return result
    }
    
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

//extension Array where Element : Equatable {
//    
//    // ... same method as above ...
//}

extension CollectionType where Index == Int {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
