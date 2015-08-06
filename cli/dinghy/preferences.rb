require 'yaml/store'

require 'dinghy/constants'

class Preferences
  LEGACY_PREFERENCES_FILE = BREW+"etc/dinghy.yml"
  PREFERENCES_FILE = HOME+"/.dinghy/preferences.yml"

  def self.load(path = PREFERENCES_FILE)
    migrate_if_necessary
    new(path)
  end

  def initialize(path)
    @store = YAML::Store.new(path)
    @store.transaction { @store[:preferences] ||= {} }
  end

  def [](attr)
    @store.transaction { @store[:preferences][attr] }
  end

  def update(config)
    @store.transaction do
      @store[:preferences] = @store[:preferences].merge(config)
    end
  end

  def self.migrate_if_necessary
    if File.file?(LEGACY_PREFERENCES_FILE) && !File.file?(PREFERENCES_FILE)
      File.rename(LEGACY_PREFERENCES_FILE, PREFERENCES_FILE)
    end
  end
end
