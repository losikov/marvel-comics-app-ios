import Foundation

struct ComicDataWrapper: Decodable {
    struct ComicDataContainer: Decodable {
        let offset: Int?
        let limit: Int?
        let total: Int?
        let count: Int?
        let results: [ComicDTO]?
    }

    let data: ComicDataContainer?
}
