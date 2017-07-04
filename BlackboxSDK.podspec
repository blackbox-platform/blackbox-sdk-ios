Pod::Spec.new do |s|
  s.name         = "BlackboxSDK"
  s.version      = File.read('version')
  s.summary      = "Blackbox platform attribution SDK."
  s.description  = <<-DESC
    Blackbox Platform is your virtual campaign manager for Apple Search Ads.

    It automatically selects keywords to bid on and automatically adjust your bid
    strategy to give you the best results for your money.

    Integrating the Blackbox SDK into your app provides the platform with additonal
    information, enabling it to inform you about the profitability of your search
    campaign, helping it further optimise your bid strategy and providing the best
    return for your money.
                   DESC
  s.homepage     = "https://www.blackbox-platform.com/"
  s.license      = "MIT"

  s.author             = { "Chris Devereux" => "chrisd@bright-interactive.co.uk" }
  s.platform     = :ios
  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/brightinteractive/blackbox-sdk-ios.git", :tag => "#{s.version}" }

  s.source_files  = "blackbox-sdk/*.{h,m}"
  s.public_header_files = "blackbox-sdk/BlackboxSDK.h"
  s.framework  = "iAd"

  s.requires_arc = true
end
