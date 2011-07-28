module Samurai::CacheableByToken
  
  # The default cache stores the values for the duration of the request
  # Different caching strategies can be employed to keep the data around longer:
  #  * class variables
  #  * Rails.cache
  #  * memcached
  #  * redis cache
  def self.included(klass)
    klass.send :cattr_accessor, :cache
    klass.send :cache=, {}
    klass.extend(ClassExtensions)
  end
  
  module ClassExtensions
    # Override the ActiveResource +find+ method to query the cache before hitting the provider.
    def find(*arguments)
      token = arguments.first
      if token.is_a?(String) && self.cache[token]
        # cache hit
        self.cache[token]
      else
        # cache miss
        obj = super(*arguments)
        self.cache[obj.id] = obj
      end
    end
  end
  
  # Overrides the ActiveResource +save+ method to update the current
  # model in the cache
  def save
    super
    # update self in the cache
    self.class.cache[self.id] = self
  end
  
end