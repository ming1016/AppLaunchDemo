//
//  TaskManager.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/12.
//

import Foundation

// Execute asynchronous tasks by group.
func executeTasksConcurrently(tasks: [@Sendable () async -> Void]) async {
    await withTaskGroup(of: Void.self) { group in
        // Add each task closure to the task group.
        for task in tasks {
            group.addTask {
                await task()
            }
        }
    }
}

// Execute low-priority asynchronous tasks.
func performLowPriorityTasks(tasks: [@Sendable () async -> Void], withTimeLimit: Double? = nil) {
    for task in tasks {
        Task.detached(priority: .background) {
            await task()
        }
    }
}

func taskgroupDemo() {
    @Sendable func doSomething(sec: UInt64 = 2) async {
        try? await Task.sleep(nanoseconds: sec * 1_000_000_000)
    }
    
    var tasks = [@Sendable () async -> Void]()
    tasks.append {
        await doSomething()
        print("Task One Completed")
    }
    tasks.append {
        await doSomething()
        print("Task Two Completed")
    }
    tasks.append {
        await doSomething()
        print("Task Three Completed")
    }
    tasks.append {
        await doSomething()
        print("Task Four Completed")
    }
    tasks.append {
        await doSomething()
        print("Task Five Completed")
    }
    
    // low-priority asynchronous function
    var backgroundTasks = [@Sendable () async -> Void]()
    
    backgroundTasks.append {
        await doSomething()
        print("Background Task One Executed")
    }
    backgroundTasks.append {
        await doSomething(sec: 10)
        print("Background Task Two Executed")
    }
    backgroundTasks.append {
        await doSomething()
        print("Background Task Three Executed")
    }
    backgroundTasks.append {
        await doSomething()
        print("Background Task Four Executed")
    }
    
    // MARK: Execute task begin
    // low-priority task
    performLowPriorityTasks(tasks: backgroundTasks)
    // group task
    Task {
        await executeTasksConcurrently(tasks: tasks)
        print("first group of tasks completed.")
        await executeTasksConcurrently(tasks: tasks)
        print("second group of tasks completed.")
        await executeTasksConcurrently(tasks: tasks)
        print("third group of tasks completed.")
        print("All tasks completed.")
    }
}


