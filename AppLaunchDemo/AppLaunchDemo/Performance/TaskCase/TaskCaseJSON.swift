//
//  TaskCaseJSON.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/14.
//

import Foundation

// Data model
struct TCItem: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
}

extension TaskCase {
    static func badJSONDecode() {
        let jsonData = TaskCase.generateLargeJSON()
        do {
            _ = try JSONDecoder().decode([TCItem].self, from: jsonData)
            
        } catch {
            print("parse failed: \(error)")
        }
        Perf.showTime("Unoptimized JSON parsing.")
    }
    
    static func goodJSONDecode() {
        Task.detached(priority: .background) {
            do {
                _ = try await parseJSON()
                Perf.showTime("Asynchronously optimize JSON parsing.")
            } catch {
                print("Parse failed: \(error)")
            }
        }
    }
    
    // Asynchronously parse JSON.
    @Sendable
    static func parseJSON() async throws -> [TCItem] {
        let jsonData = TaskCase.generateLargeJSON()
        return try JSONDecoder().decode([TCItem].self, from: jsonData)
    }
    
    static func generateLargeJSON() -> Data {
        var items: [[String: Any]] = []
        for i in 0...10000 {
            items.append([
                "id": i,
                "title": "Title \(i)",
                "description": "This is a long descriptive text used to simulate the data volume in real-world scenarios \(i)"
            ])
        }
        return try! JSONSerialization.data(withJSONObject: items)
    }
}
