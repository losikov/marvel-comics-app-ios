import CryptoKit
import Foundation

extension String {
    var md5: String {
        let digest = Insecure.MD5.hash(data: Data(utf8))

        return digest.map { byte in
            String(format: "%02hhx", byte)
        }.joined()
    }
}
