Pod::Spec.new do |s|
s.name = 'SingularitySwiftR'

s.version = '1.0.6'

s.license = 'MIT'

s.summary = 'Encapsulated SwiftR.'

s.homepage = 'https://github.com/Mqhong/SingularitySwiftR-Pod'

s.author = { "Mqhong" => "617257112@qq.com" }

s.source = { :git => 'https://github.com/Mqhong/SingularitySwiftR-Pod.git', :tag => s.version.to_s }

s.requires_arc = true

s.ios.deployment_target = '8.3'

s.source_files = 'Pod/Classes/*.Swift'

s.dependency 'SwiftR'

end

