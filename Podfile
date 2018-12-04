platform :ios, '10.0'

post_install do |installer|
  # 需要指定编译版本的第三方的名称
  exTargets = ['SnapKit', 'Toaster', 'ESPullToRefresh']
  
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

#sb
pod 'SBComponents/Kit', '~> 0.6.0'
pod 'SBComponents/Base', '~> 0.6.0'
end
