//
//  GCDBlackBox.swift
//  CIDetectorTest
//
//  Created by Patrick on 5/5/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}