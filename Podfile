platform :ios, '10.0'

# hook for install
post_install do |installer|
  exTargets = ['DTCoreText', 'DTFoundation']
  installer.pods_project.targets.each do |target|
    if exTargets.include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end

use_frameworks!

target 'SBSwiftUICoponents' do

#common
pod 'SDWebImage/Core'
pod 'DTCoreText', '~> 1.6.21'
pod 'SBPullToRefresh', '~> 2.9'
pod 'EmptyDataSet-Swift', '~> 4.2.0'
pod 'SJNavigationPopGesture', '~> 1.4.7'
pod 'IQKeyboardManagerSwift', '~> 6.2.0'
pod 'GDPerformanceView-Swift', '~> 2.0.2'

#banner
pod 'FSPagerView', '~> 0.8.1'
pod 'CHIPageControl/Jaloro', '~> 0.1.7'

#sb
pod 'SBComponents/Kit', '~> 0.6.3'
pod 'SBComponents/Base', '~> 0.6.3'
pod 'SBComponents/HTTPState', '~> 0.6.3'
pod 'SBComponents/SceneRouter', '~> 0.6.3'
end
