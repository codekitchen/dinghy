require 'yaml/store'

require 'dinghy/constants'

class Preferences
  PREFERENCES_FILE = BREW+"etc/dinghy.yml"

  def self.load(path = PREFERENCES_FILE)
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
end
