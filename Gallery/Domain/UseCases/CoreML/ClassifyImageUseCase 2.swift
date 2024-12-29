protocol ClassifyImageUseCase {
    func execute(image: UIImage) async throws -> ClassificationResult
}