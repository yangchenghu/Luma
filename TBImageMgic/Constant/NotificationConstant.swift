
import Foundation

extension NSNotification.Name {
    
    struct Creation {
        static let stausChanged = NSNotification.Name("creation.status.changed")
        
    }
    
    
    /// tabbar 相关通知
    struct Tabbar {
        static let itemSelect = NSNotification.Name("mgic.noti.tabbar.item.select")
    }
    
    struct Account {
        static let guestRegister = NSNotification.Name("mgic.noti.account.did.register")
        static let willLogin = NSNotification.Name("mgic.noti.account.will.login")
        static let didLogin = NSNotification.Name("mgic.noti.account.did.login")
        static let willLogout = NSNotification.Name("mgic.noti.account.will.logout")
        static let didLogout = NSNotification.Name("mgic.noti.account.did.logout")
        static let didUpdateToken = NSNotification.Name("mgic.noti.account.did.update.token")
        
        /// 完成注册
        static let completeRegister = NSNotification.Name("mgic.noti.account.info.complete.register")
        
        
        static let blockUser = NSNotification.Name("mgic.noti.account.block.user")
        static let unblockUser = NSNotification.Name("mgic.noti.account.unblock.user")
        
        /// account信息变化
        static let syncAccount = NSNotification.Name("mgic.noti.account.sync")
    }
    
    struct Push {
        static let receiveMsg = NSNotification.Name("mgic.noti.push.receive.msg")
    }
    
    struct Config {
        static let didLoad = NSNotification.Name("mgic.noti.config.did.load")
    }
}

