import Combine
import Foundation

class APIService {
    final func fetch<T: APIRequest>(
        for request: T
    ) -> AnyPublisher<T.ResponseDataType, Error> {
        guard var url = URL(string: request.path) else {
            assertionFailure("Failed to create url with \(request.path)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        if request.marvelAuth {
            url.append(queryItems: APIKeys.shared.marvel.urlQueryItems)
        }

        if request.method == .get, let parameters = request.parameters {
            url.append(queryItems: parameters.urlQueryItems)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        urlRequest.httpMethod = request.method.rawValue

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: T.ResponseDataType.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
