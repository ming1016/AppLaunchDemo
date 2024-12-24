//
//  Perf.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/11.
//

import Foundation

// Performance tools
struct Perf {
    static func showTime(_ des: String = "") {
        if let processStartTime = Perf.getProcessRunningTime() {
            print("Process create to \(des) time: \(String(format: "%.2f", processStartTime)) seconds")
        }
    }
    
    // sysctl get process create to current time
    static func getProcessRunningTime() -> Double? {
        var kinfo = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]

        let result = mib.withUnsafeMutableBufferPointer { mibPtr -> Int32 in
            sysctl(mibPtr.baseAddress, 4, &kinfo, &size, nil, 0)
        }

        guard result == 0 else {
            print("sysctl call failed, error code: \(result)")
            return nil
        }

        let startTimeSec = kinfo.kp_proc.p_starttime.tv_sec
        let startTimeUsec = kinfo.kp_proc.p_starttime.tv_usec
        let startTime = TimeInterval(startTimeSec) + TimeInterval(startTimeUsec) / 1_000_000
        
        let currentTime = Date().timeIntervalSince1970
        return currentTime - startTime
    }
}
