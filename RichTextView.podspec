Pod::Spec.new do |s|

  s.name         = "RichTextView"
  s.version      = "0.2"
  s.summary      = "RichTextView based On TextKit"

  s.description  = <<-DESC
                   RichTextView based On TextKit, With Mention, Hashtag Feature
                   DESC

  s.homepage     = "https://github.com/kevinzhow/RichTextView"
  s.screenshots  = "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "kevinzhow" => "kevinchou.c@gmail.com" }
  s.social_media_url   = "http://twitter.com/kevinzhow"

  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.7"

  s.source       = { :git => "https://github.com/kevinzhow/RichTextView.git", :tag => s.version }
  s.source_files  = "RichTextView/Source/*.swift"
  s.requires_arc = true

end
