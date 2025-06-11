import Foundation

public enum WalletProvider {
    case phantom
    case solflare
    case metamask

    var baseURL: String {
        switch self {
        case .phantom:
            return "https://phantom.app/"
        case .solflare:
            return "https://solflare.com/"
        case .metamask:
            return "https://metamask.app.link/"
        }
    }

    var prefix: String {
        switch self {
        case .phantom:
            return "phantom"
        case .solflare:
            return "solflare"
        case .metamask:
            return "metamask"
        }
    }
}
