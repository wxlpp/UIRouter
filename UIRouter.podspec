Pod::Spec.new do |s|
  s.name             = 'UIRouter'
  s.version          = '0.2.0.alpha'
  s.summary          = 'Swift 实现的路由解耦框架.'
  s.description      =  'Swift 实现的路由解耦框架.'

  s.homepage         = 'https://github.com/wxlpp/UIRouter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wxlpp' => 'wxlpp91@foxmail.com' }
  s.source           = { :git => 'https://github.com/wxlpp/UIRouter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_versions = '5.4'
  s.ios.frameworks = 'UIKit'
  s.default_subspecs = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/Core/*'
  end

  s.subspec 'Web' do |ss|
      ss.dependency 'UIRouter/Core'
    ss.source_files = 'Source/Web/*'
    ss.ios.frameworks = 'SafariServices'
  end
end
