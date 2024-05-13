import Foundation

final class APIKeys {
    static let shared = APIKeys()
    private init() {}

    /// Marvel
    struct MarvelKey: Encodable {
        let hash: String
        let ts: String
        let apikey: String
    }

    let marvel: MarvelKey = APIKeys.createMarvelKey()
}

// MARK: - Implementations

extension APIKeys {
    private static func salt() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    private static func createMarvelKey() -> MarvelKey {
        let salt = APIKeys.salt()
        let msg = salt + APIKeysSource.Marvel.privateKey + APIKeysSource.Marvel.publicKey
        return MarvelKey(hash: msg.md5, ts: salt, apikey: APIKeysSource.Marvel.publicKey)
    }
}
