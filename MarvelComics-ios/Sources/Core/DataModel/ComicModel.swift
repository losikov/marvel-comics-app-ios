import Foundation
import SwiftData

@Model
class ComicModel {
    let id: Int?
    let title: String?

    @Transient var text: String? {
        return texts.first
    }

    @Transient var header: String {
        return text?.isEmpty == true ? "" : "The Story"
    }

    let texts: [String]

    let thumbnailUrl: URL?
    let publicUrls: [URL]

    var isRead: Bool

    init(
        id: Int?,
        title: String?,
        texts: [String],
        thumbnailUrl: URL?,
        publicUrls: [URL],
        isRead: Bool
    ) {
        self.id = id
        self.title = title
        self.texts = texts
        self.thumbnailUrl = thumbnailUrl
        self.publicUrls = publicUrls
        self.isRead = isRead
    }

    convenience init(comic: Comic) {
        self.init(
            id: comic.id,
            title: comic.title,
            texts: comic.texts,
            thumbnailUrl: comic.thumbnailUrl,
            publicUrls: comic.publicUrls,
            isRead: false
        )
    }
}

extension ComicModel: Comic {}
