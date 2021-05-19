platform :ios, '11.0'
inhibit_all_warnings! # 消除第三方库警告
use_frameworks!

target 'EasyNet' do
  pod 'AFNetworking'

end

target 'EasyNetDemo' do
  pod 'MJExtension'
  pod 'SVProgressHUD'
  pod 'SDWebImage'
  pod 'YYCache'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
