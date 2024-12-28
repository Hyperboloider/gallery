//
//  CategorizedGrid.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import SwiftUI
import Combine

final class CategorizedGridModel: ObservableObject {
    @Published var items: [CategorizedGridItems] = []
    var onSelect: (ImageAsset) -> Void
    init(items: [CategorizedGridItems] = [], onSelect: @escaping (ImageAsset) -> Void) {
        self.items = items
        self.onSelect = onSelect
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
                                ForEach(item.models, id: \.imageAsset.id) { model in
                                    DetailsView(model: model)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .onTapGesture {
                                            self.model.onSelect(model.imageAsset)
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
