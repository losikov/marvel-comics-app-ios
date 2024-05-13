import Foundation

enum APIKeysSource {
    enum Marvel {
        /// Get keys here: https://developer.marvel.com/account
        static let publicKey = {
            let publicKey = "YOUR_PUBLIC_KEY"
            assert(publicKey != "YOUR_PUBLIC_KEY", "Update public key with your key above.")
            return publicKey
        }()
        static let privateKey = {
            let publicKey = "YOUR_PRIVATE_KEY"
            assert(publicKey != "YOUR_PRIVATE_KEY", "Update private key with your key above.")
            return publicKey
        }()
    }
}
