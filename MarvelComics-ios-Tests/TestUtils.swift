import Foundation

class TestUtils {
    private func getMockJsonData(fileName: String) throws -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let filePath = testBundle.path(forResource: fileName, ofType: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        return try String(contentsOfFile: filePath).data(using: .utf8)!
    }

    func getMock<T: Decodable>(filename: String) throws -> T {
        let decoder = JSONDecoder()
        let jsonData = try getMockJsonData(fileName: filename)
        return try decoder.decode(T.self, from: jsonData)
    }
}
