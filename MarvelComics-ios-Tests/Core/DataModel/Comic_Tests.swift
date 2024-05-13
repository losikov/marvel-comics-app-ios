@testable import MarvelComics_ios
import XCTest

final class MarvelComics_ios_Tests: XCTestCase {
    var data: ComicDataWrapper.ComicDataContainer!

    override func setUpWithError() throws {
        let container: ComicDataWrapper = try TestUtils().getMock(filename: "comics")
        data = container.data!
    }

    func testContainerParser() throws {
        XCTAssertEqual(data.results!.count, 20)
        XCTAssertEqual(data.offset, 0)
        XCTAssertEqual(data.limit, 20)
        XCTAssertEqual(data.count, 20)
        XCTAssertEqual(data.total, 59992)
    }

    func testDecoder() throws {
        let comic = data.results![3]

        XCTAssertEqual(comic.id, 323)
        XCTAssertEqual(comic.title, "Ant-Man (2003) #2")

        XCTAssertEqual(comic.textObjects!.count, 1)
        XCTAssertEqual(
            comic.textObjects![0].text,
            "Ant-Man digs deeper to find out who is leaking secret information that threatens our national security.\r\n32 pgs./PARENTAL ADVISORY...$2.99"
        )

        XCTAssertEqual(comic.thumbnail!.path, "http://i.annihil.us/u/prod/marvel/i/mg/f/20/4bc69f33cafc0")
        XCTAssertEqual(comic.thumbnail!.extension, "jpg")

        XCTAssertEqual(comic.urls!.count, 1)
        XCTAssertEqual(
            comic.urls![0].url,
            "http://marvel.com/comics/issue/323/ant-man_2003_2?utm_campaign=apiRef&utm_source=25a07f7adccf7328d3153451c26bd992"
        )
    }

    func testHelperExtension() throws {
        // object with empty data
        let comic0 = data.results![0]

        XCTAssertEqual(comic0.title, "Marvel Previews (2017)")
        XCTAssertEqual(comic0.header, "")
        XCTAssertNil(comic0.text)
        XCTAssertEqual(comic0.texts, [])
        XCTAssertNil(comic0.thumbnailUrl)
        XCTAssertEqual(comic0.publicUrls, [])

        // object with all data
        let comic3 = data.results![3]

        XCTAssertEqual(comic3.title, "Ant-Man (2003) #2")
        XCTAssertEqual(comic3.header, "The Story")
        XCTAssertEqual(
            comic3.text,
            "Ant-Man digs deeper to find out who is leaking secret information that threatens our national security.\r\n32 pgs./PARENTAL ADVISORY...$2.99"
        )
        XCTAssertEqual(
            comic3.thumbnailUrl?.absoluteString,
            "http://i.annihil.us/u/prod/marvel/i/mg/f/20/4bc69f33cafc0.jpg"
        )
        XCTAssertEqual(
            comic3.publicUrls,
            [URL(string: "http://marvel.com/comics/issue/323/ant-man_2003_2?utm_campaign=apiRef&utm_source=25a07f7adccf7328d3153451c26bd992")]
        )
    }
}
