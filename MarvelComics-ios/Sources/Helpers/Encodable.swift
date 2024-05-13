import Foundation

extension Encodable {
    var urlQueryItems: [URLQueryItem] {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            assertionFailure("Failed to encode")
            return []
        }
        guard let d = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            assertionFailure("Failed to serialize to dictionary")
            return []
        }
        return d.map { k, v in URLQueryItem(name: k, value: "\(v)") }
    }
}
