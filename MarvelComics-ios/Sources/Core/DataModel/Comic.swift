import Foundation
import SwiftData

protocol Comic {
    var id: Int? { get }
    var title: String? { get }
    var text: String? { get }
    var header: String { get }
    var texts: [String] { get }
    var thumbnailUrl: URL? { get }
    var publicUrls: [URL] { get }
}

struct ComicDTO: Decodable {
    struct TextObject: Decodable {
        let text: String?
    }

    struct Image: Decodable {
        let path: String?
        let `extension`: String?
    }

    struct Url: Decodable {
        let url: String?
    }

    let id: Int?
    let title: String?

    let textObjects: [TextObject]?

    let thumbnail: Image?
    let urls: [Url]?
}

extension ComicDTO: Comic {
    var text: String? {
        textObjects?.first?.text
    }

    var header: String {
        text?.isEmpty == false ? "The Story" : ""
    }

    var texts: [String] {
        textObjects?.compactMap { $0.text } ?? []
    }

    var thumbnailUrl: URL? {
        guard let path = thumbnail?.path, let ext = thumbnail?.extension else {
            return nil
        }
        return URL(string: path + "." + ext)
    }

    var publicUrls: [URL] {
        urls?.compactMap {
            guard let url = $0.url else {
                return nil
            }
            return URL(string: url)
        } ?? []
    }
}
