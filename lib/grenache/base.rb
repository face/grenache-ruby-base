module Grenache
  class Base
    include Grenache::Configurable

    # Lookup for a specific service `key`
    # passed block is called with the result values
    # @param key [string] identifier of the service
    def lookup(key, opts={}, &block)
      link.send('lookup', key, opts, &block)
    end

    # Announce a specific service `key` available on specific `port`
    # passed block is called when the announce is sent
    # @param key [string] service identifier
    # @param port [int] service port number
    # @block callback
    def announce(key, port, opts={}, &block)
      payload = [key,port]
      link.send 'announce', payload, opts, &block
      if config.auto_announce
        periodically(5, block) do
          link.send 'announce', payload, opts
        end
      end
    end

    private

    def periodically(seconds, block)
      EM.add_periodic_timer(seconds) do
        yield
        block.call if block
      end
    end

    def link
      @link ||= Link.new
      @link.connect unless @link.connected?
      @link
    end
  end
end
