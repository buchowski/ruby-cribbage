# frozen_string_literal: true

require_relative "lib/cribbage_game/version"

Gem::Specification.new do |spec|
  spec.name = "cribbage_game"
  spec.version = CribbageGame::VERSION
  spec.authors = ["buchowski"]
  spec.email = ["bucholz.adam@gmail.com"]

  spec.summary = "Two player cribbage card game"
  spec.homepage = "https://github.com/buchowski/ruby-cribbage"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/buchowski/ruby-cribbage"
  spec.metadata["changelog_uri"] = "https://github.com/buchowski/ruby-cribbage/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "card_deck"
  spec.add_dependency "aasm", "~> 5.0", ">= 5.0.6"
  spec.add_dependency "sum_all_number_combinations", "~> 0.1.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
