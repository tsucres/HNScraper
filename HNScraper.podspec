Pod::Spec.new do |s|
  s.name             = 'HNScraper'
  s.version          = '0.2.1'
  s.summary          = 'Scraper for hackernews written in swift'
 
  s.description      = <<-DESC
Scraper for hackernews written in swift. Supports grabbing posts, comments & user data as well as logging in, voting and favouriting items.
                       DESC
 
  s.homepage         = 'https://github.com/tsucres/HNScraper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Stéphane Sercu' => 'stefsercu@gmail.com' }
  s.source           = { :git => 'https://github.com/tsucres/HNScraper.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '9.0'
  s.source_files = 'HNScraper/**/*.swift'
 
end