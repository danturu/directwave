# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "directwave/version"

Gem::Specification.new do |s|
  s.name        = "directwave"
  s.version     = Directwave::VERSION
  s.authors     = ["Dima Kochnev"]
  s.email       = ["kochnev.d@gmail.com"]
  s.homepage    = "http://radiant.fm"
  s.summary     = %q{Ruby direct uploader to Amazon S3}
  s.description = %q{A simple way to direct upload big files to Amazon S3 storage from Ruby applications and process it with cloud encoding service.}
  s.extra_rdoc_files = ["README.md"]

  s.rubyforge_project = "directwave"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "activesupport", ["~> 3.1"]
  s.add_dependency "uuid"
  s.add_dependency "aws-sdk"

  s.add_development_dependency "rails", ["~> 3.1"]
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"
end
