//
//  AppLaunchDemoApp.swift
//  AppLaunchDemo
//
//  Created by Ming Dai on 2024/12/22.
//

import SwiftUI
import os.signpost
import BackgroundTasks
import AppIntents

@main
struct AppLaunchDemoApp: App {
    // Mark launch time
    private let launchStartTime = DispatchTime.now()
    private let signpostID = OSSignpostID(log: OSLog.default)
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Launch")
    @State private var metricsManager = MetricsManager()
    
    init() {
        os_signpost(.begin, log: log, name: "Launch", signpostID: signpostID)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // background fetch
                    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.starming.fetch", using: nil) { task in
                        self.handleAppRefresh(task: task as! BGAppRefreshTask)
                    }
                    scheduleAppRefresh()
                    
                    // Process to main view loaded time
                    if let processStartTime = Perf.getProcessRunningTime() {
                        // Main view loaded, marked
                        let launchEndTime = DispatchTime.now()
                        let launchTime = Double(launchEndTime.uptimeNanoseconds - launchStartTime.uptimeNanoseconds) / 1_000_000_000
                        
                        // Pre-main
                        print("Pre-main : \(String(format: "%.2f", (processStartTime - launchTime))) seconds")
                    } else {
                        print("Can't get process create time.")
                    }
                    
                    // Case Demo
                    TaskCase.bad()
//                    TaskCase.good()
                    
                    // Task manager
                    taskgroupDemo()
                    
                    if let processStartTime = Perf.getProcessRunningTime() {
                        // Post-main
                        print("Process create to main view time: \(String(format: "%.2f", processStartTime)) seconds")
                    }
                    
                    // Record launch end
                    os_signpost(.end, log: log, name: "Launch", signpostID: signpostID)
                }
        }
    } // end body
    
    // MARK: - Background Task
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.starming.fetch")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 15) // The earliest run is 15 minutes after.
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Background task request failed: \(error)")
        }
    }
    func handleAppRefresh(task: BGAppRefreshTask) {
        // Ensure task completed in time
        task.expirationHandler = {
            // If the task time is about to run out, cancel the task.
            task.setTaskCompleted(success: false)
        }
        
        // Simulated data retrieval
        print("Background task started, retrieving data.")
    }
}
