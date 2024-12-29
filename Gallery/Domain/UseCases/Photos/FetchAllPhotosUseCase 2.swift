protocol FetchAllPhotosUseCase {
    func execute() async throws -> [ImageAsset]
}