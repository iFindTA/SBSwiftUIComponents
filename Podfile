platform :ios, '10.0'

# hook for install
post_install do |installer|
  exTargets = ['Toaster', 'SBComponents', 'DTCoreText', 'DTFoundation']
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
