
Pod::Spec.new do |s|
  s.name             = 'MKLayout'
  s.version          = '0.1.6.1'
  s.summary          = 'This was made to make the UI easier and more concise using NSLayoutAnchor.'
  s.homepage         = 'https://github.com/dp221125/MKLayout'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dp221125' => 'dp221125@naver.com' }
  s.source           = { :git => 'https://github.com/dp221125/MKLayout.git', :tag => '0.1.6.1'}

  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/**/*'
  s.swift_version = '4.0'
  
end
