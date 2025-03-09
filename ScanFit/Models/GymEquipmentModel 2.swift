//
//  GymEquipmentModel 2.swift
//  ScanFit
//
//  Created by Lana Alyahya on 09/03/2025.
//


import CoreML
import UIKit
import Vision

class GymEquipmentModel {
    
    let classLabels_aiiigym2 = [
        "Ab Wheel", "Aerobic Stepper", "Arm Curl Machine", "Assisted Chin Up-Dip",
        "Back Extension", "Barbell", "Cable Machine", "Chest Fly Machine",
        "Chest Press Machine", "Dumbbell", "Gymball", "Hip Abductor", "Kettlebell",
        "Lat Pulldown", "Leg Extension", "Leg Press", "Leg Curl Machine",
        "Person", "Punching Bag", "Shoulder Press Machine", "Smith Machine",
        "Stationary Bike", "T-Bar Row", "Treadmill", "Seated Dip Machine",
        "Seated Cable Rows", "Lateral Raises Machine", "Chinning Dipping"
    ]
    
    let classLabels_AiGymm = [
        "Chest Press Machine", "Lat Pulldown", "Seated Cable Rows", "Arm Curl Machine",
        "Chest Fly Machine", "Chinning Dipping", "Lateral Raises Machine",
        "Leg Extension", "Leg Press", "Leg Curl Machine", "Seated Dip Machine",
        "Shoulder Press Machine", "Smith Machine"
    ]
    
    func detectGymEquipment(in image: UIImage) -> String {
        guard let pixelBuffer = convertToPixelBuffer(from: image) else {
            return "Error processing image"
        }

        let result1 = runModel(aiiigym2.self, input: pixelBuffer)
        let result2 = runModel(AiGymm.self, input: pixelBuffer)

        return result1.confidence >= result2.confidence
            ? "🔵 aiiigym2: \(result1.label) (\(String(format: "%.2f", result1.confidence))%)"
            : "🟢 AiGymm: \(result2.label) (\(String(format: "%.2f", result2.confidence))%)"
    }
    
    func runModel<T>(_ modelType: T.Type, input pixelBuffer: CVPixelBuffer) -> (label: String, confidence: Float) {
        do {
            let model: MLModel
            let inputProvider: MLFeatureProvider
            let classLabels: [String]
            
            if modelType == aiiigym2.self {
                let modelInstance = try aiiigym2(configuration: MLModelConfiguration())
                model = modelInstance.model
                inputProvider = aiiigym2Input(imagePath: pixelBuffer, iouThreshold: 0.3, confidenceThreshold: 0.05)
                classLabels = classLabels_aiiigym2
            } else if modelType == AiGymm.self {
                let modelInstance = try AiGymm(configuration: MLModelConfiguration())
                model = modelInstance.model
                inputProvider = AiGymmInput(imagePath: pixelBuffer, iouThreshold: 0.3, confidenceThreshold: 0.05)
                classLabels = classLabels_AiGymm
            } else {
                return ("Unknown Model", 0.0)
            }

            let prediction = try model.prediction(from: inputProvider)
            let confidenceArray = prediction.featureValue(for: "confidence")?.multiArrayValue?.toArray() ?? []
            
            if let maxConfidenceIndex = confidenceArray.firstIndex(of: confidenceArray.max() ?? 0) {
                let detectedEquipmentName = classLabels[maxConfidenceIndex]
                let maxConfidence = confidenceArray[maxConfidenceIndex]
                return (detectedEquipmentName, maxConfidence)
            }
        } catch {
            print("Error running model \(modelType): \(error.localizedDescription)")
        }

        return ("No Prediction", 0.0)
    }
    
    func convertToPixelBuffer(from image: UIImage?) -> CVPixelBuffer? {
        guard let image = image, let cgImage = image.cgImage else { return nil }
        
        let width = 416
        let height = 416
        
        let attributes: [NSObject: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ]

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)

        guard let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
}
