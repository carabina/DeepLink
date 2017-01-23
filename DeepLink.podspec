
Pod::Spec.new do |s|
  s.name             = 'DeepLink'
  s.version          = '0.1.0'
  s.summary          = 'Open URL more easily'

  s.description      = <<-DESC
  Open URL more easily
                       DESC
  s.homepage         = 'https://github.com/7ulipa/DeepLink'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tulipa' => 'darwin.jxzang@gmail.com' }
  s.source           = { :git => 'https://github.com/7ulipa/DeepLink.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'DeepLink/Classes/**/*'

end
