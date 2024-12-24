//
//  TaskCaseLoadFile.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/14.
//

import Foundation

extension TaskCase {
    // Synchronous reading method – will block the main thread.
    static func badLoadFile() {
        // Simulate a time-consuming operation by reducing the number of iterations and adding delays.
        var content = ""
        for i in 1...10 {
            content += "This is the content of line \(i)\n"
            Thread.sleep(forTimeInterval: 0.3) // Pause for 0.3 seconds on each iteration.
        }
        Perf.showTime("Unoptimized file reading.")
    }
    
    // Asynchronous reading method – recommended usage.
    static func goodLoadFile() {
        Task {
            do {
                _ = try await withCheckedThrowingContinuation { continuation in
                    DispatchQueue.global().async {
                        var content = ""
                        for i in 1...10 {
                            content += "This is the content of line \(i)\n"
                            Thread.sleep(forTimeInterval: 0.3) // Pause for 0.3 seconds on each iteration.
                        }
                        continuation.resume(returning: content)
                    }
                }
                
                // UI updates must be performed on the main thread.
                await MainActor.run {
                    Perf.showTime("Asynchronously optimize file reading.")
                }
            } catch {
                await MainActor.run {
                    print("Failed to read the file.")
                }
            }
        }
    }
}
