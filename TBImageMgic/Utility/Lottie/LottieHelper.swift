
import Foundation


class LottieHelper {
    
    static func lottiePath(name : String, buldle : Bundle? = nil) -> String? {
        
        if let bundle = buldle {
            return bundle.path(forResource: name, ofType: "json")
        }
        else {
            return Bundle.main.path(forResource: name, ofType: "json")
        }
    }
    
    static func lottieBundlePath(lottieName lname : String, bundleName bname: String) -> String? {
        
        var bundleName = bname
        if !bundleName.hasSuffix(".bundle") {
            bundleName = bundleName + ".bundle"
        }
        
        guard let bundlePath = Bundle.main.path(forResource: bundleName, ofType: nil) else { return nil}
        let bundle = Bundle(path: bundlePath)
                
        return Self.lottiePath(name: lname, buldle: bundle)
    }
    
    
}
