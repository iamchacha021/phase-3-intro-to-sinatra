# -*- encoding: utf-8 -*-
# stub: process-metrics 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "process-metrics".freeze
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "funding_uri" => "https://github.com/sponsors/ioquatix" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Samuel Williams".freeze]
  s.date = "2020-02-03"
  s.email = ["samuel.williams@oriontransfer.co.nz".freeze]
  s.executables = ["process-metrics".freeze]
  s.files = ["bin/process-metrics".freeze]
  s.homepage = "https://github.com/socketry/process-metrics".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.3.25".freeze
  s.summary = "Provide detailed OS-specific process metrics.".freeze

  s.installed_by_version = "3.3.25" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<console>.freeze, ["~> 1.8"])
    s.add_runtime_dependency(%q<samovar>.freeze, ["~> 2.1"])
    s.add_development_dependency(%q<covered>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.8"])
  else
    s.add_dependency(%q<console>.freeze, ["~> 1.8"])
    s.add_dependency(%q<samovar>.freeze, ["~> 2.1"])
    s.add_dependency(%q<covered>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.8"])
  end
end
