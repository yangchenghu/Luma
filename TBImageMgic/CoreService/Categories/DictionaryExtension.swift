
import Foundation

extension Dictionary where Key == String, Value == Any {
    public static func += <K, V> (left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left[k] = v
        }
    }
    
    public func stringForKey(_ key: String) -> String? {
        return (self[key] as? String)
    }
    
    public func stringValueForKey(_ key: String) -> String {
        return (self[key] as? String) ?? ""
    }
    
    public func intForKey(_ key: String) -> Int? {
        return (self[key] as? Int)
    }
    
    public func intValueForKey(_ key: String) -> Int {
        return (self[key] as? Int) ?? 0
    }
    
    public func floatForKey(_ key: String) -> CGFloat? {
        return (self[key] as? CGFloat)
    }
    
    public func floatValueForKey(_ key: String) -> CGFloat {
        return (self[key] as? CGFloat) ?? 0
    }
    
    public func boolForKey(_ key: String) -> Bool? {
        return (self[key] as? Bool)
    }
    
    public func boolValueForKey(_ key: String) -> Bool {
        if let v = self[key] as? Bool {
            return v
        }
        return intValueForKey(key) == 1
    }
    
    public func int64ForKey(_ key: String) -> Int64? {
        return (self[key] as? Int64)
    }
    
    public func int64ValueForKey(_ key: String) -> Int64 {
        return (self[key] as? Int64) ?? 0
    }
    
    public func doubleForKey(_ key: String) -> Double? {
        return (self[key] as? Double)
    }
    
    public func floatForKey(_ key: String) -> Float? {
           return (self[key] as? Float)
    }
    
    public func floatValueForKey(_ key: String) -> Float {
        return (self[key] as? Float) ?? 0
    }
    
    public func float64ForKey(_ key: String) -> Float64? {
           return (self[key] as? Float64)
    }
    
    public func float64ValueForKey(_ key: String) -> Float64 {
        return (self[key] as? Float64) ?? 0
    }

    
    public func doubleValueForKey(_ key: String) -> Double {
        return (self[key] as? Double) ?? 0.0
    }
    
    public func dictForKey(_ key: String) -> [String: Any]? {
        return (self[key] as? [String: Any])
    }
    
    public func dictValueForKey(_ key: String) -> [String: Any] {
        return (self[key] as? [String: Any]) ?? [:]
    }
    
    public func arrayForKey(_ key: String) -> [Any]? {
        return self[key] as? [Any]
    }
    
    public func arrayValueForKey(_ key: String) -> [Any] {
        return (self[key] as? [Any]) ?? []
    }
    
    public func arrayStringForKey(_ key: String) -> [String]? {
        return (self[key] as? [String])
    }
    
    public func arrayStringValueForKey(_ key: String) -> [String] {
        return (self[key] as? [String]) ?? []
    }
    
    public func arrayDictionaryForKey(_ key: String) -> [[String: Any]]? {
        return (self[key] as? [[String: Any]])
    }
    
    public func arrayDictionaryValueForKey(_ key: String) -> [[String: Any]] {
        return (self[key] as? [[String: Any]]) ?? []
    }
    
    public mutating func merge<K, V>(dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for (key, value) in dict {
                self.updateValue(value as Value, forKey: key as! Key)
            }
        }
    }
    
    public func toJson() -> String {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("无法解析出JSONString")
            return ""
        }
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            data = Data()
            return ""
        }
        let str = String(data: data, encoding: .utf8)
        return str ?? ""
    }
    
    public func toData() -> Data {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("无法解析出JSON Data")
            return Data()
        }
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            data = Data()
        }
        return data
    }
}

