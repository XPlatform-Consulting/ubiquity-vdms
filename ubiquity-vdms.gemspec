# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ubiquity/vdms/version'

Gem::Specification.new do |spec|
  spec.name          = 'ubiquity-vdms'
  spec.version       = Ubiquity::VDMS::VERSION
  spec.authors       = ['John Whitson']
  spec.email         = ['john.whitson@gmail.com']

  spec.summary       = %q{Gem and utilities to interact with Verizon Digital Media Services.}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/XPlatform-Consulting/ubiquity-vdms/blob/837efb00b62fe8fe2850055aedfb16fbca808dba/README.md'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
