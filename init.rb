begin
  require File.dirname(__FILE__) + '/lib/association_validation'
rescue LoadError => lE
  raise LoadError, "Failed to load AssociationValidation plugion: #{lE}"
end
