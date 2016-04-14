//
//  delayExtension.swift
//  Stripes
//
//  Created by Koop Otten on 12/12/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
extension Double {
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func waitSecondsAndDo (closure:()->()) {
        delay (self, closure: closure)
    }
}
