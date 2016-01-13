Pod::Spec.new do |s|
s.name = 'SingularitySwiftR'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = 'Encapsulated SwiftR.'
s.homepage = 'https://github.com/Mqhong/SingularitySwiftR'
s.author = { "Mqhong" => "617257112@qq.com" }
s.source = { :git => 'https://github.com/Mqhong/SingularitySwiftR.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '8.3'
s.source_files = 'Pod/Classes/*'
s.dependency 'SwiftR'
end

