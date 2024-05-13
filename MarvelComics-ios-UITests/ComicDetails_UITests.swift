import XCTest

final class MarvelComics_ios_UITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func testCloseButton() throws {
        let app = XCUIApplication()
        app.launch()

        // open Comic
        let collectionViewsQuery = app.collectionViews
        let comicItem = collectionViewsQuery.children(matching: .cell).element(boundBy: 0)
            .otherElements.containing(.staticText, identifier: "Marvel Previews (2017)").element

        XCTAssertTrue(comicItem.waitForExistence(timeout: 5.0), "Comics not loaded")
        comicItem.tap()

        // close Comic
        let closeButton = app.navigationBars["MarvelComics_ios.ComicsDetailsCollectionView"].buttons["Close"]
        XCTAssertTrue(closeButton.exists, "Don't have close button")
        closeButton.tap()

        XCTAssertTrue(comicItem.exists, "Doesn't close Comic details")
    }

    func testNextPreviousButtonsBaseNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // open Comic
        let collectionViewsQuery = app.collectionViews
        let comicItem = collectionViewsQuery.children(matching: .cell).element(boundBy: 2).otherElements.containing(.staticText, identifier: "Marvel Previews (2017)").element
        XCTAssertTrue(comicItem.waitForExistence(timeout: 5.0), "Comics not loaded")
        comicItem.tap()

        let elementsQuery = collectionViewsQuery/*@START_MENU_TOKEN@*/ .cells/*[[".scrollViews.cells",".cells"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ .scrollViews.otherElements
        let comicDetailsTitle1 = elementsQuery.staticTexts["Marvel Previews (2017)"]
        XCTAssertTrue(comicDetailsTitle1.exists, "Doesn't open Comic")

        // go NEXT
        let toolbar = app.toolbars["Toolbar"]
        toolbar/*@START_MENU_TOKEN@*/ .staticTexts["NEXT"]/*[[".buttons[\"NEXT\"].staticTexts[\"NEXT\"]",".staticTexts[\"NEXT\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ .tap()

        let comicDetailsTitle2 = elementsQuery.staticTexts["Ant-Man (2003) #2"]
        XCTAssertTrue(comicDetailsTitle2.exists, "Doesn't open next Comic")

        // go PREVIOUS
        toolbar/*@START_MENU_TOKEN@*/ .staticTexts["PREVIOUS"]/*[[".buttons[\"PREVIOUS\"].staticTexts[\"PREVIOUS\"]",".staticTexts[\"PREVIOUS\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ .tap()
        XCTAssertTrue(comicDetailsTitle2.exists, "Doesn't open previous Comic")
    }
}
