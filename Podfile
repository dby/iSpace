# Uncomment the next line to define a global platform for your project
inhibit_all_warnings!
use_frameworks!

target 'iSecrets' do
  pod 'JFHeroBrowser', :path => './'
  pod 'WCDB.swift'
  pod 'Kingfisher', '~> 7.0'
  pod 'AlertToast'
  pod 'FirebaseAnalytics'
  pod 'Google-Mobile-Ads-SDK'
  pod 'SnapKit', '~> 5.0.0'
end

# post install
post_install do |installer|
  # fix xcode 15 DT_TOOLCHAIN_DIR - remove after fix oficially - https://github.com/CocoaPods/CocoaPods/issues/12065
  installer.aggregate_targets.each do |target|
      target.xcconfigs.each do |variant, xcconfig|
      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
          xcconfig_path = config.base_configuration_reference.real_path
          IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
    end
  end
end
