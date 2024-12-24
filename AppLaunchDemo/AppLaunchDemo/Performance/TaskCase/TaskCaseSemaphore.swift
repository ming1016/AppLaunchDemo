//
//  TaskCaseSemaphore.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/14.
//

import Foundation

extension TaskCase {
    static func badSemaphore() {
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global().async {
            // Simulate a time-consuming operation.
            sleep(2)
            semaphore.signal()
        }
        
        // Wait for a semaphore, which will block the main thread.
        semaphore.wait()
        Perf.showTime("Unoptimized semaphore.")
    }
    
    static func goodSemaphore() {
        Task {
            await performAsyncTask()
            Perf.showTime("Asynchronously optimize the semaphore.")
        }
        
        // Asynchronous task function.
        @Sendable
        func performAsyncTask() async {
            try? await Task.sleep(for: .seconds(2))
        }
    }
}
