Pod::Spec.new do |s|
  s.name     = 'Amalon'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'An engine for simulating games of Avalon(Resistance).'
  s.homepage = 'https://github.com/TokenGnome/Amalon'
  s.authors  = { 'Brandon Smith' => 'brcosm@gmail.com', 'Nathaniel Troutman' => 'nathanieltroutman@gmail.com' }
  s.source   = { :git => '.', :tag => '0.0.1' }
  s.source_files = 'AvalonEngine'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.ios.frameworks = 'JavaScriptCore'
  s.osx.deployment_target = '10.9'
  s.osx.frameworks = 'JavaScriptCore'
end