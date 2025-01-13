import Foundation

enum DemoSettings {

    private static let EnvironmentDefaultsKey = "environment"
    private static let ClientIDKey = "clientID"

    static var environment: Environment {
        get {
            UserDefaults.standard.string(forKey: EnvironmentDefaultsKey)
                .flatMap { Environment(rawValue: $0) } ?? .sandbox
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: EnvironmentDefaultsKey)
        }
    }
}
