//
//  AsyncImageView.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import SwiftUI
import Photos

struct AsyncImageView: View {
    @StateObject private var loader = AsyncImageLoader()
    let identifier: String
    let placeholder: Image
    let targetSize: CGSize
    
    init(identifier: String, placeholder: Image = Image(systemName: "photo"), targetSize: CGSize = CGSize(width: 300, height: 300)) {
        self.identifier = identifier
        self.placeholder = placeholder
        self.targetSize = targetSize
    }
    
    var body: some View {
        Group {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            loader.loadImage(by: identifier, targetSize: targetSize)
        }
    }
}

class AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    func loadImage(by identifier: String, targetSize: CGSize = CGSize(width: 300, height: 300)) {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        
        guard let asset = fetchResult.firstObject else {
            print("Asset not found for identifier \(identifier)")
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: nil
            ) { [weak self] image, _ in
                let a = 1
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}

