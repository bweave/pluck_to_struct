# frozen_string_literal: true

require_relative "lib/pluck_to_struct/version"

Gem::Specification.new do |spec|
  spec.name = "pluck_to_struct"
  spec.version = PluckToStruct::VERSION
  spec.authors = ["Brian Weaver"]
  spec.email = ["bdrums@gmail.com"]

  spec.summary = "Pluck ActiveRecord models to lightweight Structs for wicked fast performance."
  spec.description = spec.summary
  spec.homepage = "https://github.com/bweave/pluck_to_struct.git"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"

  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rerun"
  spec.add_development_dependency "rubocop", "~> 1.56"
  spec.add_development_dependency "solargraph"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "syntax_tree"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
