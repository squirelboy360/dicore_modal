Pod::Spec.new do |s|
  s.name             = 'dicore_modal'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for native modals'
  s.description      = <<-DESC
A Flutter plugin for native modals with full customization support.
                       DESC
  s.homepage         = 'https://github.com/squirelboy360/dicore_modal'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'diCore' => 'squirelwares@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform         = :osx, '10.11'
  s.swift_version    = '5.0'
end