import Foundation

extension FileManager {
    func getUniqueURL(for originalURL: URL) -> URL {
        let directory = originalURL.deletingLastPathComponent()
        let fileName = originalURL.deletingPathExtension().lastPathComponent
        let ext = "gif"
        
        var targetURL = directory.appendingPathComponent("\(fileName).\(ext)")
        var counter = 1
        
        while fileExists(atPath: targetURL.path) {
            targetURL = directory.appendingPathComponent("\(fileName)_\(counter).\(ext)")
            counter += 1
        }
        return targetURL
    }
}
