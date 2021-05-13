# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

$TekoSpecs = 'https://' + ENV['GITHUB_USER_TOKEN'] + '@github.com/teko-vn/Specs-ios.git'   # for using pods from Teko

source 'https://github.com/CocoaPods/Specs.git' # for using pods from cocoaPods
source $TekoSpecs   # for using pods from Teko

# bitcode enable
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      
      # set valid architecture
      config.build_settings['VALID_ARCHS'] = 'arm64 armv7 armv7s x86_64'

      # build active architecture only (Debug build all)
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      
      # Xcode 12 have to exclude arm64 for simulator architecture
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

      config.build_settings["BUILD_LIBRARY_FOR_DISTRIBUTION"] = "YES"

      if config.name == 'Release'
        config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
        else # Debug
        config.build_settings['BITCODE_GENERATION_MODE'] = 'marker'
      end
      
      cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
      
      if config.name == 'Release'
        cflags << '-fembed-bitcode'
        else # Debug
        cflags << '-fembed-bitcode-marker'
      end
      
      config.build_settings['OTHER_CFLAGS'] = cflags
    end
  end
end

def janusPods
  pod 'Janus', '~> 3.2.1', source: $TekoSpecs
  pod 'JanusFacebook', '~> 3.2.3', source: $TekoSpecs
  pod 'JanusGoogle', '~> 3.2.3', source: $TekoSpecs

end


target 'PaymentDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PaymentDemo
  pod 'Terra', '~> 2.5.3', source: $TekoSpecs
  pod 'MinervaUI', '~> 3.8.2', source: $TekoSpecs
  janusPods
  pod 'DropDown'
  pod 'IQKeyboardManagerSwift'


  target 'PaymentDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PaymentDemoUITests' do
    # Pods for testing
  end

end
