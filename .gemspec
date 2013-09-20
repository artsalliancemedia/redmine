# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "aam_lifeguard"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.author      = "Arts Alliance Media"
  s.email       = ["development@artsalliancemedia.com"]
  s.homepage    = "http://www.artsalliancemedia.com"
  s.summary     = "Lifeguard for digital cinema."
  s.description = "Tools for a digital cinema network operations centre built on top of Redmine."
  s.license     = "GPL v2"

  # Which files should be included in the gem itself, hopefully basically everything in the lib folder.
  s.files       = Dir["lib/**/*"]
  s.files.reject! { |f| f.include? "core_patches" }
  s.files.reject! { |f| f.include? ".git" }

  # External dependencies, please install these separately.
  s.requirements << 'ruby, v2.0.x'
  s.requirements << 'rubygems, v2.0.x'
  s.requirements << 'postgresql, v9.3.x'

  # Ruby dependencies, hopefully gems should magically install these.
  s.add_runtime_dependency "rails", "3.2.13"
  s.add_runtime_dependency "jquery-rails", "~> 2.0.2"
  s.add_runtime_dependency "i18n", "~> 0.6.0"
  s.add_runtime_dependency "coderay", "~> 1.0.9"
  s.add_runtime_dependency "fastercsv", "~> 1.5.0"
  s.add_runtime_dependency "builder", "3.0.0"
  s.add_runtime_dependency "pg", ">= 0.11.0"
end