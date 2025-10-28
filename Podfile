source 'https://github.com/CocoaPods/Specs.git'

use_modular_headers!
workspace 'TBImageMgic'
version = '13.0'
platform :ios, version
inhibit_all_warnings!

# m1 cpu 支持模拟器
post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "i386"
        end
      end
    end
end


def network
  pod 'Alamofire'
  pod 'SDWebImage', '5.12.1'
  pod 'SDWebImageWebPCoder', '0.8.4'
  pod 'SDWebImagePhotosPlugin', '1.2.0'
  pod 'CocoaLumberjack', '3.7.4'
  pod 'CachingPlayerItem'
end

def ui
  pod 'MJRefresh', '3.7.2'
  pod 'ProgressHUD'
  pod 'lottie-ios' # , '3.2.3'
  pod 'Toast-Swift', '~> 5.1.1'
  pod 'FTPopOverMenu'
  pod 'FSPopoverView'
  pod 'HWPanModal'
  pod 'SDCycleScrollView', '1.82', :modular_headers => true
end

def yykit
  pod 'YYCache'
  pod 'YYText'
  pod 'YYCategories', '1.0.4'
end

def custom_pods
    
end

def js_bridge
  pod "dsBridge", '3.0.6', :modular_headers => true
end

def report 
  pod 'Adjust', '~> 4.38.4'
  pod 'FirebaseAnalytics'
  # pod 'FBSDKCoreKit', '~> 8.0.0'
end

def utils
  pod 'L10n-swift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Then'
  pod 'HandyJSON'
  pod 'SwiftyStoreKit'
  pod 'KeychainAccess'
end

def mainApp_pods
  network
  ui
  yykit
  custom_pods
  js_bridge
  utils
  report
end

target 'TBImageMgic' do
	project 'TBImageMgic.xcodeproj'
	mainApp_pods
end

