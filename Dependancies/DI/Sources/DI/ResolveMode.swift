//
//  ResolveMode.swift
//
//
//  Created by Illia Kniaziev on 18.08.2024.
//

import Foundation

/// Allow you to choose how you'd like the dependency resolved
public enum ResolveMode {
    /// Indicate that you'd like a new dependency created of that type or key requested
    case new
    /// Indicate that you'd like the global dependency of that type or key requested
    case shared
}
