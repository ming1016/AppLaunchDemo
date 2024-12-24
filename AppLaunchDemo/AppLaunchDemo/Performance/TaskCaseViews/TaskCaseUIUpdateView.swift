//
//  TaskCaseUIUpdate.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/13.
//

import SwiftUI

struct CardItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
}

// User data model.
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let company: Company
    
    struct Company: Codable {
        let name: String
    }
}

struct TaskCaseUIUpdateView: View {
    @State private var users: [User] = []
    @State private var cards: [CardItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    var isBad = true
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Generating card...")
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150), spacing: 16)
                ], spacing: 16) {
                    ForEach(cards) { card in
                        CardView(item: card)
                    }
                }
                .padding()
            }
            
            HStack(spacing: 20) {
                // Synchronously update UI – causes stuttering.
                Button("Synchronously(stuttering)") {
                    updateCardsSynchronously()
                }
                
                // Asynchronously update UI – recommended approach.
                Button("Asynchronously") {
                    Task {
                        await updateCardsAsynchronously()
                    }
                }
                
                // Clear button
                Button("Clear") {
                    cards.removeAll()
                }
            }
        }
        .onAppear {
            if isBad == true {
                updateCardsSynchronously()
            } else {
                Task {
                    await updateCardsAsynchronously()
                }
            }
        }
        .padding()
        .frame(height: 300)
    }
    
    // Card view component.
    struct CardView: View {
        let item: CardItem
        
        var body: some View {
            VStack {
                Text(item.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(item.color)
                    .cornerRadius(8)
            }
        }
    }
    
    // Synchronously update – will block the main thread.
    private func updateCardsSynchronously() {
        // Generate 1000 cards at once.
        var newCards: [CardItem] = []
        for i in 1...1000 {
            // Simulate complex UI calculations.
            Thread.sleep(forTimeInterval: 0.001) // Add a 1 millisecond delay for each card.
            let color = Color(
                red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1)
            )
            newCards.append(CardItem(title: "Card #\(i)", color: color))
        }
        cards = newCards
    }
    
    // Asynchronous update – recommended usage.
    @MainActor
    private func updateCardsAsynchronously() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newCards = try await withThrowingTaskGroup(of: [CardItem].self) { group in
                // Process in batches, 100 cards per batch.
                let batchSize = 100
                let totalCards = 1000
                var allCards: [CardItem] = []
                
                for batchStart in stride(from: 0, to: totalCards, by: batchSize) {
                    group.addTask {
                        var batchCards: [CardItem] = []
                        let end = min(batchStart + batchSize, totalCards)
                        
                        for i in (batchStart + 1)...end {
                            // Simulate complex UI calculations.
                            try await Task.sleep(nanoseconds: 1_000_000) // 1 millisecond.
                            let color = Color(
                                red: .random(in: 0...1),
                                green: .random(in: 0...1),
                                blue: .random(in: 0...1)
                            )
                            batchCards.append(CardItem(title: "Card #\(i)", color: color))
                        }
                        return batchCards
                    }
                }
                
                // Collect the results of all batches.
                for try await batchCards in group {
                    allCards.append(contentsOf: batchCards)
                }
                
                return allCards
            }
            
            // Update UI
            self.cards = newCards
            self.isLoading = false
            
        } catch {
            self.errorMessage = "Failed to generate cards: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
