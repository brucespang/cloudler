require './lib/clouder.rb'

Gem::Specification.new do |s|
  s.name = 'clouder'
  s.version = 0.1
  s.authors = ["Bruce Spang"]
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.email = %q{bruce@brucespang.com}

	s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.summary = %q{Runs a command on a remote server}
	s.executables = %w(cloud)
	s.default_executable = 'cloud'
end

