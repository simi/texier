rake_version = Gem::Version.new(Rake::VERSION)
rude_rake = Gem::Requirement.new('>=0.9.2')

if rude_rake.satisfied_by?(rake_version) and respond_to?(:link, true)
  undef :link
end

