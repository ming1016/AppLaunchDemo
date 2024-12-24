//
//  TaskCasePriorityView.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/13.
//

import SwiftUI
import Combine

struct CalculationTask: Sendable {
    let id: Int
    let iterations: Int
}

struct CalculationResult: Sendable {
    let taskId: Int
    let result: Double
}

// View model
@MainActor
final class CalculationPriorityViewModel: ObservableObject, @unchecked Sendable {
    @Published var results: [Int: Double] = [:]
    @Published var isCalculating = false
    @Published var animationOffset: CGFloat = 0
    private var animationTimer: AnyCancellable?
    
    // Improper use of high priority (which can cause UI stuttering).
    func runHighPriorityTasks(iter: Int = 1) async {
        isCalculating = true
        let tasks = (1...10).map { id in
            CalculationTask(id: id, iterations: iter)
        }
        
        // Run all tasks with high priority.
        await withTaskGroup(of: CalculationResult.self) { group in
            for task in tasks {
                group.addTask(priority: .high) { // 默认优先级
                    await self.heavyCalculation(task)
                }
            }
            
            for await result in group {
                results[result.taskId] = result.result
            }
        }
        
        isCalculating = false
    }
    
    // Use appropriate priority (for smooth UI).
    func runOptimizedTasks(iter: Int = 1) async {
        isCalculating = true
        let tasks = (1...10).map { id in
            CalculationTask(id: id, iterations: iter)
        }
        
        // Run compute-intensive tasks with lower priority.
        await withTaskGroup(of: CalculationResult.self) { group in
            for task in tasks {
                group.addTask(priority: .background) { // Low priority.
                    await self.heavyCalculation(task)
                }
            }
            
            for await result in group {
                results[result.taskId] = result.result
            }
        }
        
        isCalculating = false
    }
    
    // Compute-intensive function.
    private func heavyCalculation(_ task: CalculationTask) async -> CalculationResult {
        var result = 0.0
        for i in 0..<task.iterations {
            result += sin(Double(i))
        }
        return CalculationResult(taskId: task.id, result: result)
    }
    
    // Start UI animation.
    func startAnimation() {
        animationTimer = Timer.publish(every: 1/60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateAnimation()
            }
    }
    
    // Stop UI animation
    func stopAnimation() {
        animationTimer?.cancel()
        animationTimer = nil
    }
    
    private func updateAnimation() {
        withAnimation(.linear(duration: 1/60)) {
            animationOffset = animationOffset < 100 ? animationOffset + 1 : 0
        }
    }
}

struct TaskCasePriorityView: View {
    @StateObject private var viewModel = CalculationPriorityViewModel()
    var isBad = true
    
    var body: some View {
        VStack(spacing: 30) {
            // Animation indicator.
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .offset(x: viewModel.animationOffset)
                .animation(.linear(duration: 1/60), value: viewModel.animationOffset)
            
            // Display calculation results.
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(Array(viewModel.results.sorted(by: { $0.key < $1.key })), id: \.key) { id, result in
                        Text("Task \(id): \(String(format: "%.2f", result))")
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .frame(height: 200)
            .border(Color.gray.opacity(0.2))
            
            HStack(spacing: 20) {
                Button("high priority(stuttering)") {
                    Task {
                        await viewModel.runHighPriorityTasks()
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Optimize(smooth)") {
                    Task {
                        await viewModel.runOptimizedTasks()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            if viewModel.isCalculating {
                ProgressView()
                    .padding()
            }
        }
        .padding()
        .onAppear {
            viewModel.startAnimation()
            if isBad == true {
                Task {
                    await viewModel.runHighPriorityTasks(iter: 500000)
                    Perf.showTime("High-priority execution completed.")
                }
            } else {
                var tasks = [@Sendable () async -> Void]()
                for _ in 0...10 {
                    tasks.append {
                        await viewModel.runOptimizedTasks(iter: 50000)
                    }
                }
                performLowPriorityTasks(tasks: tasks)
                Perf.showTime("Low-priority execution completed.")
            }
        }
        .onDisappear {
            viewModel.stopAnimation()
        }
    }
}
