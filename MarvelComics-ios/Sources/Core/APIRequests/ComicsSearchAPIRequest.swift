import Foundation

struct ComicsSearchAPIRequestParameters: Encodable {
    let titleStartsWith: String
    let offset: Int
}

struct ComicsSearchAPIRequest: APIRequest {
    typealias RequestDataType = ComicsSearchAPIRequestParameters
    typealias ResponseDataType = ComicDataWrapper

    let path: String = "https://gateway.marvel.com:443/v1/public/comics"

    let method: HTTPMethod = .get
    let marvelAuth: Bool = true

    let parameters: ComicsSearchAPIRequestParameters?
    let name: String

    init(name: String, offset: Int) {
        self.name = name
        if name.isEmpty {
            parameters = nil
        } else {
            parameters = ComicsSearchAPIRequestParameters(
                titleStartsWith: name,
                offset: offset
            )
        }
    }
}
