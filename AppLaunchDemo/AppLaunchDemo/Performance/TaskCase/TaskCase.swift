//
//  BadCase.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/13.
//

import Foundation

struct TaskCase {
    static func bad() {
        TaskCase.badLoadFile() // Load file
        TaskCase.badSemaphore() // Semaphore
        TaskCase.badJSONDecode() // JSON parse
    }
    
    static func good() {
        TaskCase.goodLoadFile() // Load file
        TaskCase.goodSemaphore() // Semaphore
        TaskCase.goodJSONDecode() // JSON parse
    }
    
}
