import Combine
import Foundation
import SwiftData

class Storage {
    static let `default` = Storage()

    private let modelContainer: ModelContainer?
    private let modelContext: ModelContext?

    private init() {
        if let modelContainer = try? ModelContainer(
            for: ComicModel.self
        ) {
            self.modelContainer = modelContainer
            modelContext = ModelContext(modelContainer)
        } else {
            modelContainer = nil
            modelContext = nil
        }
    }

    func insert(_ comicModel: ComicModel) {
        let id = comicModel.id
        try? modelContext?.delete(
            model: ComicModel.self,
            where: #Predicate<ComicModel> { $0.id == id }
        )
        modelContext?.insert(comicModel)
        try? modelContext?.save()
    }

    func delete(_ comicModel: ComicModel) {
        modelContext?.delete(comicModel)
        try? modelContext?.save()
    }

    func isMarkedAsReadPublisher(id: Int?) -> AnyPublisher<Bool, Never> {
        guard let id else {
            return Just(false).eraseToAnyPublisher()
        }

        let predicate = #Predicate<ComicModel> { $0.id == id && $0.isRead == true }
        let descriptor = FetchDescriptor<ComicModel>(predicate: predicate)

        let result = CurrentValueSubject<Bool?, Never>(nil)

        DispatchQueue.global(qos: .default).async { [weak self] in
            let isMarkedAsRead = ((try? self?.modelContext?.fetch(descriptor).count) ?? 0) > 0
            result.send(isMarkedAsRead)
        }

        return result.compactMap { $0 }.eraseToAnyPublisher()
    }
}
