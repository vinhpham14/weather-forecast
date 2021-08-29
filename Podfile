# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

workspace 'WeatherForecastApp.xcworkspace'

target 'WeatherForecastApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WeatherForecastApp

  target 'WeatherForecastAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'WeatherForecastAppUITests' do
    # Pods for testing
  end

end

target 'SearchForecast' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  project 'AppFeatures/SearchForecast/SearchForecast.xcodeproj'

  target 'SearchForecastTests' do
    inherit! :search_paths
  end

end