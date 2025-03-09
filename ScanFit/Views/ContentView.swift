//
//  ContentView.swift
//  ScanFit
//
//  Created by Lana Alyahya on 09/03/2025.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GymEquipmentViewModel()

    var body: some View {
        VStack {
            Text("Gym Equipment Detector")
                .font(.largeTitle)
                .padding()

            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(10)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
                    .padding()
            }

            Text("Detected: \(viewModel.detectedEquipment)")
                .font(.headline)
                .padding()

            HStack {
                Button(action: {
                    viewModel.sourceType = .photoLibrary
                    viewModel.showImagePicker = true
                }) {
                    Label("Choose from Gallery", systemImage: "photo.on.rectangle")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    viewModel.sourceType = .camera
                    viewModel.showImagePicker = true
                }) {
                    Label("Take Photo", systemImage: "camera")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: viewModel.sourceType)
        }
        .onChange(of: viewModel.selectedImage) { newImage in
            viewModel.detectEquipment()
        }
    }
}
