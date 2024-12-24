//
//  TaskCaseAnimation.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/13.
//

import SwiftUI
import Combine

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var color: Color
    var size: CGFloat
}

@MainActor
final class ParticleSystem: ObservableObject, @unchecked Sendable {
    @Published var particles: [Particle] = []
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Not optimized.
    func createParticles(at position: CGPoint, count: Int) {
        // Creating a large number of particles on the main thread (which may cause stuttering).
        for _ in 0..<count {
            let particle = Particle(
                position: position,
                velocity: CGPoint(
                    x: CGFloat.random(in: -5...5),
                    y: CGFloat.random(in: -5...5)
                ),
                color: Color(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1)
                ),
                size: .random(in: 2...6)
            )
            particles.append(particle)
        }
    }
    
    // optimized
    @MainActor
    func createParticlesAsync(at position: CGPoint, count: Int) async {
        // Create a static function to generate particle data.
        let newParticles = await Task.detached(priority: .userInitiated) {
            return await Self.generateParticles(at: position, count: count)
        }.value
        
        particles.append(contentsOf: newParticles)
    }
    
    // Static function to generate particles.
    private static func generateParticles(at position: CGPoint, count: Int) -> [Particle] {
        return (0..<count).map { _ in
            Particle(
                position: position,
                velocity: CGPoint(
                    x: CGFloat.random(in: -5...5),
                    y: CGFloat.random(in: -5...5)
                ),
                color: Color(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1)
                ),
                size: .random(in: 2...6)
            )
        }
    }
    
    func startAnimation() {
        // Use `Timer.publish` instead of `Timer.scheduledTimer`.
        Timer.publish(every: 1/60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateParticles()
            }
            .store(in: &cancellables)
    }
    
    private func updateParticles() {
        particles = particles.compactMap { particle in
            var newParticle = particle
            newParticle.position.x += particle.velocity.x
            newParticle.position.y += particle.velocity.y
            // Remove particles that are off-screen.
            if newParticle.position.y > 1000 || newParticle.position.x < -100 || newParticle.position.x > 500 {
                return nil
            }
            return newParticle
        }
    }
    
    func stopAnimation() {
        cancellables.removeAll()
    }
}

struct TaskCaseAnimationView: View {
    @StateObject private var particleSystem = ParticleSystem()
    var isBad = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Draw all particles.
            ForEach(particleSystem.particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
            }
            
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    // The version that causes stuttering.
                    Button("1000 particles (stuttering).") {
                        particleSystem.createParticles(
                            at: CGPoint(x: 200, y: 400),
                            count: 1000
                        )
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)
                    
                    // The version that does not cause stuttering.
                    Button("Asynchronously 1000 particles.") {
                        Task {
                            await particleSystem.createParticlesAsync(
                                at: CGPoint(x: 200, y: 400),
                                count: 1000
                            )
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            particleSystem.startAnimation()
            if isBad == true {
                particleSystem.createParticles(
                    at: CGPoint(x: 200, y: 400),
                    count: 1000
                )
            } else {
                Task {
                    await particleSystem.createParticlesAsync(
                        at: CGPoint(x: 200, y: 400),
                        count: 1000
                    )
                }
            }
        }
        .onDisappear {
            particleSystem.stopAnimation()
        }
        .frame(height: 300)
    }
}
