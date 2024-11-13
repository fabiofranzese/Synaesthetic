import Foundation

extension FileManager {
    static func loadFile(named filename: String, withExtension ext: String = "js") -> String? {
        guard let path = Bundle.main.path(forResource: filename, ofType: ext) else {
            print("Failed to find \(filename).\(ext)")
            return nil
        }
        
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            print("Failed to load \(filename).\(ext): \(error)")
            return nil
        }
    }
}
