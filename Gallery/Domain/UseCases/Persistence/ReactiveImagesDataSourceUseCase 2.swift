protocol ReactiveImagesDataSourceUseCase {
    func createImagesDataSource(withGroupingStrategy groupingStrategy: GroupingPreference) -> AnyPublisher<[CategorizedImageSet], Never>
}