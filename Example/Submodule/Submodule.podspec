#
# Be sure to run `pod lib lint UIRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Submodule'
  s.version          = '0.1.0'
  s.summary          = 'Submodule for Example.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wxlpp/Submodule'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wxlpp' => 'wxlpp91@foxmail.com' }
  s.source           = { :git => 'https://github.com/wxlpp/Submodule.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/**/*'
  s.ios.frameworks = 'UIKit'
  s.dependency 'UIRouter'
end
