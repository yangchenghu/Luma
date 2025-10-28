
import Foundation

extension Array where Element: Equatable {
 
    @discardableResult
    public mutating func remove(_ object: Element) -> Bool {
        if let index = firstIndex(of: object) {
            remove(at: index)
            return true
        }
        return false
    }
}
