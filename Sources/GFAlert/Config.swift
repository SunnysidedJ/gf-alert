import Foundation

struct Config: Codable {
    let intervalMinutes: Int
    let message: String

    static let defaultConfig = Config(
        intervalMinutes: 60,
        message: "Hey! Time to text your girlfriend :)"
    )

    static func load() -> Config {
        let userConfigURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/gf-alert/config.json")

        if let data = try? Data(contentsOf: userConfigURL),
           let config = try? JSONDecoder().decode(Config.self, from: data),
           config.intervalMinutes > 0 {
            return config
        }

        // Fall back to bundled config next to the executable
        let bundledURL = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("config.json")

        if let data = try? Data(contentsOf: bundledURL),
           let config = try? JSONDecoder().decode(Config.self, from: data),
           config.intervalMinutes > 0 {
            return config
        }

        return defaultConfig
    }
}
