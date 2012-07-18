# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scribd-carrierwave/version"

Gem::Specification.new do |s|
  s.name        = "scribd-carrierwave"
  s.version     = ScribdCarrierWave::VERSION
  s.authors     = ["Aubrey Rhodes"]
  s.email       = ["aubrey.c.rhodes@gmail.com"]
  s.homepage    = ""
  s.summary     = "Integration for rscirbd and carrierwave"
  s.description = "Allows you to have a CarrierWave uploader automatically upload to scribd"

  s.rubyforge_project = "scribd-carrierwave"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "mocha", "~> 0.10.0"
  s.add_development_dependency "cover_me"
  s.add_development_dependency "rake"
  s.add_runtime_dependency "rscribd"
  s.add_runtime_dependency "carrierwave"
  s.add_runtime_dependency "configatron"
end
