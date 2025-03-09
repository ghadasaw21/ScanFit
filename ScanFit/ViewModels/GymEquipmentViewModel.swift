//
//  GymEquipmentViewModel.swift
//  ScanFit
//
//  Created by Lana Alyahya on 09/03/2025.
//


import SwiftUI
import UIKit

class GymEquipmentViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var detectedEquipment: String = "No Prediction Yet"
    @Published var showImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    private var gymEquipmentModel = GymEquipmentModel()

    func detectEquipment() {
        if let image = selectedImage {
            detectedEquipment = gymEquipmentModel.detectGymEquipment(in: image)
        }
    }
}
