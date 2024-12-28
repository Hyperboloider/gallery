//
//  GalleryViewModelActions.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Photos

struct GalleryViewModelActions {
    var requestPhotosAccess: () async -> PHAuthorizationStatus
}
