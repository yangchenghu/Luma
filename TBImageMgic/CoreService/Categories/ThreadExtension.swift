
import Foundation

extension Thread {
    public static func doInMainThread(_ block: @escaping (() -> Void)) {
        if self.isMainThread { block() }
        else { DispatchQueue.main.async { block() } }
    }
    
    public static func after(seconds: TimeInterval, block: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: block)
    }
    
    public static func asyncTask(_ block: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            block()
        }
    }
}
