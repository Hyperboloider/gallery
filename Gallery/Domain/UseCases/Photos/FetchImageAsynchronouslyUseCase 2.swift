protocol FetchImageAsynchronouslyUseCase {
    func execute(requestedId: String, targetSize: CGSize) async throws -> UIImage
}