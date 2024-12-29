protocol ImagesWithLocationsUseCase {
    func execute() -> AnyPublisher<[MapAssetAnnotation], Never>
}