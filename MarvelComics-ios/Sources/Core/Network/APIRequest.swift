import Foundation

enum HTTPMethod: String {
    case get
}

protocol APIRequest {
    associatedtype RequestDataType: Encodable
    associatedtype ResponseDataType: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var marvelAuth: Bool { get }

    var parameters: RequestDataType? { get }
}
