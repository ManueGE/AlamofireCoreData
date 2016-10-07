Pod::Spec.new do |spec|

  spec.name         = "AlamofireCoreData"
  spec.version      = "0.0.1"
  spec.summary      = "A nice Alamofire serializer that convert JSON into CoreData using Groot."
  spec.description  = <<-DESC
  A nice Alamofire serializer that convert JSON into CoreData using Groot.
                   DESC
  spec.homepage     = "https://github.com/ManueGE/AlamofireCoreData/"
  spec.license      = "MIT"

  spec.author    = "Manuel García-Estañ"
  spec.social_media_url   = "http://twitter.com/ManueGE"

  spec.platform     = :ios, "8.0"
  spec.source       = { :git => "https://github.com/ManueGE/AlamofireCoreData.git", :tag => "#{spec.version}" }

  spec.requires_arc = true
  spec.dependency "Alamofire", "~> 4.0"
  spec.dependency "Alamofire", "~> 2.0"

  spec.source_files = "source/**/*.{swift}"
  sepc.framework  = "CoreData"

  spec.subspec 'Core' do |core|
    core
  end

end
