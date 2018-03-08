#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "StockChart"
  s.version          = '1.1.0'
  s.summary          = "A stock chart with a range selector"
  s.description      = <<-DESC
                       This chart demonstrates the various financial chart types offered by ShinobiCharts, as well
			as containing a range selector.
                       DESC
  s.homepage         = "https://www.shinobicontrols.com"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Alison Clarke" => "aclarke@shinobicontrols.com" }
  s.source           = { :git => "https://github.com/ShinobiControls/play-stock-chart.git",
                         :tag => s.version.to_s,
                         :submodules => true
                       }
  s.social_media_url = 'https://twitter.com/shinobicontrols'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'StockChart/StockChart/**/*.{h,m}'
  s.dependency 'ShinobiPlayUtils'
  s.resources = ['StockChart/**/*.storyboard', 'StockChart/**/*.xib', 'StockChart/**/*.xcassets', 'StockChart/**/StockChartData.plist']
  s.frameworks = 'QuartzCore', 'ShinobiCharts'
  s.libraries = 'c++'
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(DEVELOPER_FRAMEWORKS_DIR)" "$(PROJECT_DIR)/../"' }
end
