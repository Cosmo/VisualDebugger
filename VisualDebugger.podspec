Pod::Spec.new do |s|
  s.name        = "VisualDebugger"
  s.version     = "3.0.0"
  s.summary     = "VisualDebugger makes it easy to deal with JSON data in Swift"
  s.homepage    = "https://github.com/VisualDebugger/VisualDebugger"
  s.license     = { :type => "MIT" }
  s.authors     = { "lingoer" => "lingoerer@gmail.com", "tangplin" => "tangplin@gmail.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source   = { :git => "https://github.com/VisualDebugger/VisualDebugger.git", :tag => s.version }
  s.source_files = "Source/*.swift"
end
