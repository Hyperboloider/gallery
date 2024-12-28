//
//  DetailsViewModel.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation
import UIKit

final class DetailsViewModel: ObservableObject {
    let imageAsset: ImageAsset
    let showsDetails: Bool
    private let imageUseCase: FetchImageAsynchronouslyUseCase
    @Published var image: UIImage?
    
    init(
        imageAsset: ImageAsset,
        imageUseCase: FetchImageAsynchronouslyUseCase,
        showsDetails: Bool = true
    ) {
        self.imageAsset = imageAsset
        self.imageUseCase = imageUseCase
        self.showsDetails = showsDetails
        
        Task {
            let image = try await imageUseCase.execute(
                requestedId: imageAsset.id,
                targetSize: showsDetails ? CGSize(width: 512, height: 512) : CGSize(width: 200, height: 200)
            )
            
            await MainActor.run {
                self.image = image
            }
        }
    }
}
