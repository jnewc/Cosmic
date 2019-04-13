Pod::Spec.new do |s|

  s.name         = "Cosmic"
  s.version      = "5.0.0"
  s.summary      = "A log reporting framework written in Swift"

  s.description  = <<-DESC
  Cosmic is a log reporting framework written in Swift.

  For more information, see the readme at: https://github.com/jnewc/Cosmic.git
  DESC

  s.homepage     = "http://cosmic.newcombe.io"

  s.license      = "Apache 2.0"

  s.author             = { "Jack Newcombe" => "jack@newcombe.io" }
  s.social_media_url   = "http://twitter.com/jacknewc"

  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.11"

  s.source       = { :git => "https://github.com/jnewc/Cosmic.git", :tag => "#{s.version}" }

  s.source_files  = "ObjC-Sources/**/*.swift", "Sources/**/*.swift"

  s.dependency "BlueSocket", "~> 1.0"

end
