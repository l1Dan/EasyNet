Pod::Spec.new do |spec|
  spec.name         = "EasyNet"
  spec.version      = "1.0.0"
  spec.summary      = "EasyNet base-on AFNetworking for iOS."

  spec.description  = <<-DESC
  EasyNet base-on AFNetworking for iOS。是一个简单易用的 iOS 网络请求库，基于 AFNetworking。简单几句代码就能快速搭建一个网络请求。
                   DESC

  spec.homepage     = "https://github.com/l1Dan/EasyNet"

  spec.license      = "MIT"
  spec.author       = { "Leo Lee" => "l1dan@hotmail.com" }
  spec.source       = { :git => "https://github.com/l1Dan/EasyNet.git", :tag => "#{spec.version}" }

  spec.ios.deployment_target = "11.0"
  spec.default_subspec       = "Sources"
  spec.swift_version         = '5.0'
  spec.cocoapods_version     = '>= 1.4.0'
  spec.source_files  = "EasyNet/*.h"

  spec.subspec "Sources" do |ss|
    ss.source_files  = "EasyNet/Core/*.{h,m}", "EasyNet/Categories/*.{h,m}"
    ss.private_header_files = "EasyNet/Categories/ENConnectTask+Private.h"
    ss.dependency "AFNetworking", "~> 4.0"
    ss.framework  = "Foundation"
  end

  spec.subspec "RxSwift" do |ss|
    ss.source_files = "EasyNet/RxEasyNet/"
    ss.dependency "EasyNet/Sources"
    ss.dependency "RxSwift", "~> 6.0"
  end

end
