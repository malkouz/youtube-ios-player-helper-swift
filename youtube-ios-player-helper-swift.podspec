

Pod::Spec.new do |s|
  s.name             = 'youtube-ios-player-helper-swift'
  s.version          = '1.0'
  s.summary          = 'Helper library for iOS developers looking to add YouTube video playback in their applications via the iframe player in a UIWebView.'

  s.description      = <<-DESC
A full swift implementation of https://github.com/youtube/youtube-ios-player-helper. Helper library for iOS developers looking to add YouTube video playback in their applications via the iframe player in a UIWebView.
                       DESC

  s.homepage         = 'https://github.com/malkouz/youtube-ios-player-helper-swift'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author           = { 'Moayad Al kouz' => 'moayad_kouz9@hotmail.com' }
  s.source           = { :git => 'https://github.com/malkouz/youtube-ios-player-helper-swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/malkouz'

  s.ios.deployment_target = '8.0'

  s.source_files = 'youtube-ios-player-helper-swift/Classes/**/*'
  
   s.resource_bundles = {
     'youtube-ios-player-helper-swift' => ['youtube-ios-player-helper-swift/Assets/*']
  }
end
