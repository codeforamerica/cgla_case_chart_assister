
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cgla_case_chart_assister/version"

Gem::Specification.new do |spec|
  spec.name          = "cgla_case_chart_assister"
  spec.version       = CglaCaseChartAssister::VERSION
  spec.authors       = ["Christa Hartsock", "Symonne Singleton", "Molly Trombley-McCann"]
  spec.email         = ["christa@codeforamerica.org", "symonne@codeforamerica.org", "mollyt@codeforamerica.org"]
  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md CODE_OF_CONDUCT.md CGLA_CASE_CHART_FILLABLE.pdf)

  spec.summary       = "A toolkit for filling expungement and sealing case charts used by Cabrini Green Legal Aid in Illinois."
  spec.description   = "A toolkit for filling expungement and sealing case charts used by Cabrini Green Legal Aid in Illinois."
  spec.homepage      = "https://github.com/codeforamerica/cgla_case_chart_filler"
  spec.license       = "MIT"
  # spec.executables += %w{fill_csv fill_pdf}

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/codeforamerica/cgla_case_chart_filler"
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "pdf-forms", "~> 1.2"
  spec.add_dependency "roo", "~> 2.8"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
