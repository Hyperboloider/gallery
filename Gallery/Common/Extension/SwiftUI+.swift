//
//  SwiftUI+.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation

import SwiftUI

extension View {
    /// Applies a transformation to the view if a condition is true.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies one of two transformations to the view based on a condition.
    @ViewBuilder
    func ifElse<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}
