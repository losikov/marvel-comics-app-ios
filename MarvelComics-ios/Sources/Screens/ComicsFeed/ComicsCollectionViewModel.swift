import Combine
import Foundation

class ComicsCollectionViewModel {
    enum State {
        case loading
        case data
        case loadingMoreData
        case noData
        case error(String?)
    }

    struct Item: Equatable {
        static func == (lhs: ComicsCollectionViewModel.Item, rhs: ComicsCollectionViewModel.Item) -> Bool {
            return lhs.comic.id == rhs.comic.id && lhs.markedAsRead == rhs.markedAsRead
        }

        let comic: Comic
        let markedAsRead: Bool

        var thumbnailImageUrl: URL? {
            comic.thumbnailUrl
        }

        var publicUrl: URL? {
            comic.publicUrls.first
        }

        var name: String? {
            comic.header
        }

        var title: String? {
            comic.title
        }

        var text: String? {
            comic.text
        }
    }

    @Published private(set) var state: State = .loading
    @Published private var comics: [Comic] = []

    private var totalCount = 0

    private var searchName: String = ""

    @Published var currentIndex: Int = 0
    private var requestCancellable: AnyCancellable?

    func item(at index: Int) -> AnyPublisher<Item, Never>? {
        if index < comics.count {
            return $comics.map {
                $0[index]
            }
            .combineLatest(Storage.default.isMarkedAsReadPublisher(id: comics[index].id))
            .map {
                Item(comic: $0.0, markedAsRead: $0.1)
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        } else if index == comics.count, index < totalCount {
            search(searchName, offset: index)
        }
        return nil
    }

    var count: AnyPublisher<Int, Never> {
        $comics.map { [weak self] in
            $0.isEmpty ? 0 : min($0.count + 1, self?.totalCount ?? 0)
        }
        .removeDuplicates()
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func comic(at index: Int) -> Comic? {
        if index < comics.count {
            return comics[index]
        } else if index == comics.count, index < totalCount {
            search(searchName, offset: index)
        }
        return nil
    }

    func search(_ name: String, offset: Int) {
        if searchName != name {
            state = .loading
            searchName = name
            comics = []
        } else if offset > 0 {
            state = .loadingMoreData
        } else {
            state = .loading
        }

        let request = ComicsSearchAPIRequest(name: searchName, offset: offset)
        requestCancellable = APIService().fetch(for: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case let .failure(failure):
                    self?.state = .error(failure.localizedDescription)
                }
            }, receiveValue: { [weak self] comicData in
                self?.updateDataModel(data: comicData)
            })
    }

    func markAsRead(_ item: Item) {
        let comicModel = ComicModel(comic: item.comic)
        comicModel.isRead = !item.markedAsRead
        Storage.default.insert(comicModel)
        comics = comics
    }

    private func updateDataModel(data: ComicDataWrapper) {
        totalCount = data.data?.total ?? comics.count
        comics.append(
            contentsOf: data.data?.results ?? []
        )
        state = comics.isEmpty ? .noData : .data
    }
}
