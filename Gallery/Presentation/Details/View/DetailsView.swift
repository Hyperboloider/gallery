//
//  DetailsView.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import SwiftUI

struct DetailsView: View {
    @StateObject var model: DetailsViewModel
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            if model.showsDetails {
                if let coordinate = model.imageAsset.location?.coordinate {
                    Text("Location: Lat \(coordinate.latitude) Lon \(coordinate.longitude)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Divider()
                Text("Category: \(model.imageAsset.aiCategory ?? "Unclassified")")
                    .font(.headline)
                    .foregroundColor(.primary)
                Divider()
                Text("\(model.imageAsset.creationDate ?? .distantPast, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Divider()
                Text("\(model.imageAsset.pixelWidth)x\(model.imageAsset.pixelHeight)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .ifElse(model.showsDetails) {
                        $0.scaledToFit()
                    } else: {
                        $0.scaledToFill()
                    }
            }
            
            if model.showsDetails {
                Spacer()
            }
        }
        .if(model.showsDetails) {
            $0.padding()
        }
    }
}
