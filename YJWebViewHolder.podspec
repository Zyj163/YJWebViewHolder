#
#  Be sure to run `pod spec lint YJWebViewHolder.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name = 'YJWebViewHolder'
s.version = '0.0.1'
s.license = 'MIT'
s.summary = 'easy use WKWebView in Swift'
s.homepage = 'https://github.com/Zyj163/YJWebViewHolder'
s.authors = { 'zhangyj' => 'izyj194250@163.com' }
s.source = { :git => 'https://github.com/Zyj163/YJWebViewHolder.git', :tag => s.version }

s.ios.deployment_target = '8.0'

s.source_files = 'YJWebViewHolder/*.swift'

end
