# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spectator/version'

Gem::Specification.new do |spec|
  spec.name          = 'netflix-spectator-rb'
  spec.version       = Spectator::VERSION
  spec.authors       = ['Daniel Muino']
  spec.email         = ['dmuino@netflix.com']
  spec.licenses      = ['Apache-2.0']

  spec.required_ruby_version = '>= 2.5'

  spec.summary       = 'Simple library for instrumenting code to record ' \
    'dimensional time series.'
  spec.description   = 'Library for instrumenting ruby applications, ' \
    'sending metrics to an Atlas aggregator service.'
  spec.homepage      = 'https://github.com/Netflix/spectator-rb'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.55'
end
