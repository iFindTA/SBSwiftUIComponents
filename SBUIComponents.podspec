Pod::Spec.new do |s|

  s.name         = "SBUIComponents"
  s.version      = "1.0.3"
  s.summary      = "a swift base ui components"
  s.description  = <<-DESC
       一个swift的UI基础库，包括BaseScene, BaseProfile, BaseInput etc.
                   DESC

  s.homepage     = "https://github.com/iFindTA/"
  s.license      = "MIT"
  s.author       = { "nanhu" => "nanhujiaju@gmail.com" }
  s.platform     = :ios,'9.0'
  s.source       = { :git => "https://github.com/iFindTA/SBSwiftUIComponents.git", :tag => "#{s.version}" }
  s.ios.deployment_target = '9.0'
  s.framework    = "UIKit","Foundation"
  s.requires_arc = true
  #s.dependency 

  # custom dependencies
  s.subspec 'Commons' do |cm|
    cm.source_files = "SBSwiftUICoponents/SBCommons/*.swift"
    cm.dependency 'SBPullToRefresh'
    cm.dependency 'SJNavigationPopGesture'
    cm.dependency 'IQKeyboardManagerSwift'
    cm.dependency 'GDPerformanceView-Swift'
  end
  ## custom uis

  s.subspec 'Banner' do |bn|
    bn.source_files = "SBSwiftUICoponents/SBBanner/*.swift"
    bn.dependency 'FSPagerView'
    bn.dependency 'SDWebImage/Core'
    bn.dependency 'CHIPageControl/Jaloro'
    bn.dependency 'SBComponents/Macros'
  end

  s.subspec 'Panels' do |pn|
    pn.source_files = "SBSwiftUICoponents/SBPanels/*.swift"
    pn.framework = "WebKit"
    pn.dependency 'SBComponents/Base'
  end

  s.subspec 'Scenes' do |ss|
    ss.source_files = "SBSwiftUICoponents/SBScenes/*.swift"
    ss.resources = "SBSwiftUICoponents/SBScenes/Assets/*.*"
    ss.dependency 'SBComponents/Kit'
    ss.dependency 'SDWebImage/Core'
    ss.dependency 'IQKeyboardManagerSwift'
  end

  # 暂时不用更新，可继续使用 SBComponents/Scan~>0.6.0
  s.subspec 'Scan' do |q|
    q.source_files = "SBSwiftUICoponents/SBScan/*.swift"
    q.resources = "SBSwiftUICoponents/SBScan/Assets/*.*"
    q.framework = "CoreGraphics", "AVFoundation"
    q.dependency 'SBComponents/Kit'
    q.dependency 'SBComponents/SceneRouter'
  end

  s.subspec 'Empty' do |p|
    p.source_files = "SBSwiftUICoponents/SBEmpty/*.swift"
    p.resources = "SBSwiftUICoponents/SBEmpty/Assets/*.*"
    p.dependency 'EmptyDataSet-Swift'
    p.dependency 'SBComponents/Base'
    p.dependency 'SBComponents/HTTPState'
  end

  s.subspec 'WebBrowser' do |w|
    w.source_files = "SBSwiftUICoponents/SBBrowser/*.swift"
    w.resources = "SBSwiftUICoponents/SBBrowser/Assets/*.*"
    w.framework = "WebKit"
    w.dependency 'SDWebImage/Core'
    w.dependency 'SBComponents/Kit'
    w.dependency 'SBComponents/Base'
    w.dependency 'SBComponents/SceneRouter'
  end

  s.subspec 'Navigator' do |n|
    n.source_files = "SBSwiftUICoponents/SBNavigator/*.swift"
    n.dependency 'SBComponents/Base'
    n.dependency 'SBComponents/Macros'
  end

  s.subspec 'AudioIndicator' do |a|
    a.source_files = "SBSwiftUICoponents/SBAudioIndicator/*.swift"
    a.dependency 'SBComponents/Macros'
  end

end
