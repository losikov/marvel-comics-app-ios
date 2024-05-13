import Foundation

struct ComicThumbnailAPIRequest: APIRequest {
    typealias RequestDataType = String
    typealias ResponseDataType = Data

    let path: String

    let method: HTTPMethod = .get
    let marvelAuth: Bool = false

    let parameters: String? = nil
    let name: String

    init(url: URL) {
        name = ""
        path = url.absoluteString
    }
}
