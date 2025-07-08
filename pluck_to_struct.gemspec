require_relative 'lib/pluck_to_struct/version'

Gem::Specification.new do |spec|
  spec.name          = 'pluck_to_struct'
  spec.version       = PluckToStruct::VERSION
  spec.authors       = [ 'PluckToStruct' ]
  spec.email         = [ 'maintainer@plucktostruct.com' ]

  spec.summary       = 'Pluck ActiveRecord attributes into Struct instances'
  spec.description   = <<~DESC
    A Ruby gem that extends ActiveRecord models with a pluck_to_struct method
    that returns Struct instances instead of ActiveRecord objects.'
  DESC
  spec.homepage      = 'https://github.com/example/pluck_to_struct'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/example/pluck_to_struct'
  spec.metadata['changelog_uri'] = 'https://github.com/example/pluck_to_struct/blob/main/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    if Dir.exist?('.git')
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    else
      Dir['**/*'].reject { |f| f.match(%r{^(test|spec|features)/}) || File.directory?(f) }
    end
  end
  spec.bindir        = 'bin'
  spec.executables   = [ 'console' ]
  spec.require_paths = [ 'lib' ]

  spec.add_dependency 'activerecord', '>= 5.0'

  spec.add_development_dependency 'activesupport', '>= 5.0'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-focus', '~> 1.4'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop-rails-omakase'
  spec.add_development_dependency 'sqlite3', '>= 2.1'
end
