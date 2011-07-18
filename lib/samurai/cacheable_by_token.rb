module Samurai::CacheableByToken
  
  def self.included(klass)
    # The default cache stores the values for the duration of the request
    # Different caching strategies can be employed to keep the data around longer:
    #  Rails.cache
    #  memecached
    #  redis cache
    klass.send :cattr_accessor, :cache
    klass.send :cache=, {}
    klass.extend(ClassExtensions)
  end
  
  module ClassExtensions
    # Override the current find method to query the cache before hitting the provider.
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
  
end