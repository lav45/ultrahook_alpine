# -*- encoding: utf-8 -*-
# stub: ultrahook 0.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "ultrahook".freeze
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib/".freeze]
  s.authors = ["Vinay Sahni".freeze]
  s.date = "2015-07-20"
  s.description = "UltraHook lets you receive webhooks on localhost.  It relays HTTP POST requests sent from a public endpoints (provided by the ultrahook.com service) to private endpoints accessible from your computer.".freeze
  s.email = "vinay@sahni.org".freeze
  s.executables = ["ultrahook".freeze]
  s.files = ["bin/ultrahook".freeze, "lib/ultrahook.rb", "lib/ultrahook/client.rb", "lib/ultrahook/version.rb"]
  s.homepage = "http://www.ultrahook.com".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.11".freeze
  s.summary = "Receive webhooks on localhost".freeze

  s.add_dependency(%q<net-http-persistent>.freeze, [">= 0"])

  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>.freeze, [">= 1.8.0"])
    else
      s.add_dependency(%q<json>.freeze, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<json>.freeze, [">= 1.8.0"])
  end
end

