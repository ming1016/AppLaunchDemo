//
//  MetricManager.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/11.
//

#if os(iOS)
import MetricKit

@MainActor
class MetricsManager: NSObject, @preconcurrency MXMetricManagerSubscriber {
    static let shared = MetricsManager()
    
    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    // Receive callback for performance report.
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            if let launchMetrics = payload.applicationLaunchMetrics {
                // This represents the time when the first CA commit is finished.
                print(launchMetrics.histogrammedTimeToFirstDraw)
            }
        }
    }
    
    deinit {
        MXMetricManager.shared.remove(self)
    }
}

#endif
