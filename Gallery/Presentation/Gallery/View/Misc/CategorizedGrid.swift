//
//  CategorizedGrid.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import SwiftUI
import Combine

final class CategorizedGridModel: ObservableObject {
    @Published var items: [CategorizedImageSet] = []
    init(items: [CategorizedImageSet] = []) {
        self.items = items
    }
}

struct CategorizedGrid: View {
    @ObservedObject var model: CategorizedGridModel
    @State private var columnCount: Int = 0
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let columns = Int((availableWidth + 8) / (100 + 8))
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(model.items, id: \.category) { item in
                        Section(header: Text(item.category).font(.headline)) {
                            LazyVGrid(
                                columns: Array(
                                    repeating: GridItem(.fixed(100), spacing: 8),
                                    count: columns
                                ),
                                spacing: 8
                            ) {
                                ForEach(item.images, id: \.id) { asset in
                                    VStack {
                                        AsyncImageView(identifier: asset.id)
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                        if let date = asset.creationDate {
                                            Text("\(date, formatter: dateFormatter)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .onAppear {
                    columnCount = columns
                }
            }
        }
    }
}

#Preview {
    CategorizedGrid(model: .init(items: [
        CategorizedImageSet(category: "Category 1", images: [
            .init(id: "1", pixelWidth: 0, pixelHeight: 0),
            .init(id: "2", pixelWidth: 0, pixelHeight: 0),
            .init(id: "2-475C-4727-A4A4-B77AA9980897/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "3-FEEF-40E1-8BB3-7DD55A43C8B7/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "4-475C-4727-A4A4-B77AA9980897/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "5-FEEF-40E1-8BB3-7DD55A43C8B7/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "6-475C-4727-A4A4-B77AA9980897/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "7-FEEF-40E1-8BB3-7DD55A43C8B7/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "8-475C-4727-A4A4-B77AA9980897/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "9-FEEF-40E1-8BB3-7DD55A43C8B7/L0/001", pixelWidth: 0, pixelHeight: 0),
        ]),
        CategorizedImageSet(category: "Category 2", images: [
            .init(id: "CC95F08C-88C3-4012-9D6D-64A413D254B3/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "ED7AC36B-A150-4C38-BB8C-B6D696F4F2ED/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "9F983DBA-EC35-42B8-8773-B597CF782EDD/L0/001", pixelWidth: 0, pixelHeight: 0),
            .init(id: "106E99A1-4F6A-45A2-B320-B0AD4A8E8473/L0/001", pixelWidth: 0, pixelHeight: 0)
        ])
    ]))
}
