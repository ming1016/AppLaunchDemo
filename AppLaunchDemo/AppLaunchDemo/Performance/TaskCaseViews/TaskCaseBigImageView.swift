//
//  TaskCaseBigImageView.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/13.
//

import SwiftUI
import Observation

#if os(iOS)
@MainActor @Observable
final class ImageProcessor {
    var processedImages: [UIImage] = []
    var isProcessing = false
    
    // Synchronously process images (which blocks the main thread).
    func processImagesSynchronously() {
        // Simulate loading multiple large images.
        let imageCount = 10
        processedImages.removeAll()
        
        for i in 0..<imageCount {
            // Create a large-sized gradient image.
            let size = CGSize(width: 2000, height: 2000)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { context in
                let colors = [
                    UIColor(red: CGFloat(i)/CGFloat(imageCount), green: 0.5, blue: 0.5, alpha: 1.0),
                    UIColor(red: 0.5, green: CGFloat(i)/CGFloat(imageCount), blue: 0.5, alpha: 1.0)
                ]
                
                let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: colors.map { $0.cgColor } as CFArray,
                    locations: [0.0, 1.0]
                )!
                
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: .zero,
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
                
                // Simulate a time-consuming operation.
                Thread.sleep(forTimeInterval: 0.2)
            }
            
            // Process image – Resize.
            let processedImage = processImage(image)
            processedImages.append(processedImage)
        }
    }
    
    // Asynchronously process the image.
    func processImagesAsync() async {
        isProcessing = true
        processedImages.removeAll()
        
        // create and process an array of image tasks asynchronously
        async let images = withTaskGroup(of: UIImage.self) { group in
            for i in 0..<10 {
                group.addTask {
                    // Create a large-sized gradient image.
                    let size = CGSize(width: 2000, height: 2000)
                    let renderer = UIGraphicsImageRenderer(size: size)
                    
                    let image = renderer.image { context in
                        let colors = [
                            UIColor(red: CGFloat(i)/10.0, green: 0.5, blue: 0.5, alpha: 1.0),
                            UIColor(red: 0.5, green: CGFloat(i)/10.0, blue: 0.5, alpha: 1.0)
                        ]
                        
                        let gradient = CGGradient(
                            colorsSpace: CGColorSpaceCreateDeviceRGB(),
                            colors: colors.map { $0.cgColor } as CFArray,
                            locations: [0.0, 1.0]
                        )!
                        
                        context.cgContext.drawLinearGradient(
                            gradient,
                            start: .zero,
                            end: CGPoint(x: size.width, y: size.height),
                            options: []
                        )
                        
                        // Simulate a time-consuming operation.
                        Thread.sleep(forTimeInterval: 0.2)
                    }
                    
                    return await self.processImage(image)
                }
            }
            
            var results: [UIImage] = []
            for await image in group {
                results.append(image)
            }
            return results
        }
        
        // Wait for all image processing to complete and update the UI.
        processedImages = await images
        isProcessing = false
    }
    
    private func processImage(_ image: UIImage) -> UIImage {
        let targetSize = CGSize(width: 200, height: 200)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

struct TaskCaseBigImageView: View {
    @State private var processor = ImageProcessor()
    var isBad = true
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100))
            ], spacing: 10) {
                ForEach(Array(processor.processedImages.enumerated()), id: \.offset) { _, image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                }
            }
            .padding()
            
            VStack(spacing: 20) {
                Button("Synchronously(stuttering).") {
                    processor.processImagesSynchronously()
                }
                .buttonStyle(.bordered)
                
                Button("Asynchronously") {
                    Task {
                        await processor.processImagesAsync()
                    }
                }
                .buttonStyle(.bordered)
                
                if processor.isProcessing {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            if isBad == true {
                processor.processImagesSynchronously()
            } else {
                Task {
                    await processor.processImagesAsync()
                }
            }
        }
    }
}
#endif

