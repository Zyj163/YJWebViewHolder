Pod::Spec.new do |s|

s.name = 'YJWebViewHolder'
s.version = '1.2.2'
s.license = { :type => "MIT", :file => "LICENSE" }
s.summary = 'easy use WKWebView in Swift'

s.description  = <<-DESC
easy to use WKWebView/Alert in Swift
DESC

s.homepage = 'https://github.com/Zyj163/YJWebViewHolder'
s.authors = { 'zhangyj' => 'zyj194250@163.com' }
s.source = { :git => 'https://github.com/Zyj163/YJWebViewHolder.git', :tag => s.version }

s.ios.deployment_target = '8.0'

s.source_files = 'YJWebViewHolder/*.swift'

s.subspec 'YJEasyAlert' do |y|
y.source_files = 'YJWebViewHolder/YJEasyAlert.swift'
y.frameworks = 'UIKit'
y.requires_arc = true
end

s.requires_arc = true
s.frameworks = "UIKit", "WebKit"

s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

end
