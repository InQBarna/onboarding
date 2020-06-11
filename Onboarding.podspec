Pod::Spec.new do |s|
  s.name             = 'Onboarding'
  s.version          = '1.0.1'
  s.summary          = 'Helper pod for building app onboarding with multiple steps and version checking'
  s.swift_version    = '5.1'

  s.description      = <<-DESC
Wraps WhatsNewKit to do version checking and display:
    app blocking screen with link to appstore udpate
    whatsNew screen for a specific update and for a fresh install
    custom steps with custom screens
    DESC

  s.homepage         = 'http://gitlab.inqbarna.com/alexis/onboarding'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'alexis' => 'alexis.katsaprakakis@inqbarna.com' }
  s.source           = { :git => 'http://gitlab.inqbarna.com/alexis/onboarding', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/Onboarding/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'WhatsNewKit'
end
