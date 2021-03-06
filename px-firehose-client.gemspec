# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'px/service/firehose/version'

Gem::Specification.new do |spec|
  spec.name          = "px-firehose-client"
  spec.version       = Px::Service::Firehose::VERSION
  spec.authors       = ["Paul Xue", "Kevin Martin"]
  spec.email         = ["pxue@500px.com", "kevin@500px.com"]
  spec.summary       = %q{Ruby wrapper for AWS Kinesis Firehose}
  spec.homepage      = "https://github.com/Melraidin/px-firehose-client"
  spec.description   = "Wrapper with circuit breakers for AWS Kinesis Firehose client."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "px-service-legacy-client", "~> 1.0.4"
  spec.add_dependency "circuit_breaker", "~> 1.1"
  spec.add_dependency "aws-sdk", "~> 2.7"
  spec.add_dependency "redis", "~> 3"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_development_dependency "rspec", "~> 0"
  spec.add_development_dependency "timecop", "~> 0"
end
