
import Foundation


class BaseCellViewModel {
    var identifier : String = "BaseCellViewModel"
    var cellIdentifier : String = ""
    
    var clickBlock : (() -> Void)?
    var cellHeight : CGFloat = 0

}
