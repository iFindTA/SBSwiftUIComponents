Pod::Spec.new do |s|

  s.name         = "SBComponents"
  s.version      = "0.6.0"
  s.summary      = "a swift base ui components"
  s.description  = <<-DESC
       一个swift的UI基础库，包括BaseScene, BaseProfile, BaseInput etc.
                   DESC

  s.homepage     = "https://github.com/iFindTA/"
  s.license      = "MIT"
  s.author       = { "nanhu" => "nanhujiaju@gmail.com" }
  s.platform     = :ios,'10.0'
  s.source       = { :git => "https://github.com/iFindTA/SBSwiftUIComponents.git", :tag => "#{s.version}" }
  s.ios.deployment_target = '10.0'
  s.framework    = "UIKit","Foundation"
  s.requires_arc = true
  #s.dependency 

  ## custom uis
  s.subspec 'Panels' do |pn|
    pn.source_files = "SBComponents/SBPanels/*.swift"
    pn.dependency 'SBComponents/Base'
    pn.dependency 'DTCoreText'
    pn.dependency 'SDWebImage/Core'
  end

  s.subspec 'Scenes' do |ss|
    ss.source_files = "SBComponents/SBScenes/*.swift"
    ss.resources = "SBComponents/SBScenes/Assets/*.*"
    ss.dependency 'SBComponents/Kit'
    ss.dependency 'SDWebImage/Core'
  end

  s.subspec 'Banner' do |bn|
    bn.source_files = "SBComponents/SBBanner/*.swift"
    bn.dependency 'FSPagerView'
    bn.dependency 'SDWebImage/Core'
    bn.dependency 'CHIPageControl/Jaloro'
    bn.dependency 'SBComponents/Macros'
  end

end
