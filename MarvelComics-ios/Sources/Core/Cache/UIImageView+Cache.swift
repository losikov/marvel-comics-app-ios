import UIKit

extension UIImageView {
    func loadImageWithUrl(
        _ url: URL,
        placeholder: UIImage? = nil,
        startedHandler: (() -> Void)? = nil,
        completionHandler: @escaping (UIImage?) -> Void
    ) {
        startedHandler?()

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Failed to load image for '\(url)': \(error)")
                DispatchQueue.main.async {
                    completionHandler(placeholder)
                }
                return
            }

            guard
                let data = data,
                let image = UIImage(data: data)
            else {
                print("Invalid image for '\(url)'")
                DispatchQueue.main.async {
                    completionHandler(placeholder)
                }
                return
            }

            DispatchQueue.main.async {
                completionHandler(image)
            }
        }.resume()
    }
}
