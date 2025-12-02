Gem::Specification.new do |spec|
  spec.name         = "tracereplay"
  spec.version      = "0.0.0"
  spec.summary      = "dumps a history of the main thread backtraces so you can inspect them with you mouse in browser"

  spec.author       = "Victor Maslov aka Nakilon"
  spec.email        = "nakilon@gmail.com"
  spec.license      = "MIT"
  spec.metadata     = {"source_code_uri" => "https://github.com/nakilon/tracereplay"}

  spec.files        = %w{ LICENSE tracereplay.gemspec lib/tracereplay.rb }
end
