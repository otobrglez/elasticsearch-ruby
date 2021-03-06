module Elasticsearch
  module Transport
    module Transport
      module HTTP

        # The default transport implementation, using the [_Faraday_](https://rubygems.org/gems/faraday)
        # library for abstracting the HTTP client.
        #
        # @see Transport::Base
        #
        class Faraday
          include Base

          # Performs the request by invoking {Transport::Base#perform_request} with a block.
          #
          # @return [Response]
          # @see    Transport::Base#perform_request
          #
          def perform_request(method, path, params={}, body=nil)
            super do |connection, url|
              connection.connection.run_request \
                method.downcase.to_sym,
                url,
                ( body ? __convert_to_json(body) : nil ),
                {}
            end
          end

          # Builds and returns a collection of connections.
          #
          # @return [Connections::Collection]
          #
          def __build_connections
            Connections::Collection.new \
              :connections => hosts.map { |host|
                host[:protocol]   = host[:scheme] || DEFAULT_PROTOCOL
                host[:port]     ||= DEFAULT_PORT
                url               = __full_url(host)

                Connections::Connection.new \
                  :host => host,
                  :connection => ::Faraday::Connection.new( :url => url, &@block )
              },
              :selector_class => options[:selector_class],
              :selector => options[:selector]
          end

          # Returns an array of implementation specific connection errors.
          #
          # @return [Array]
          #
          def host_unreachable_exceptions
            [::Faraday::Error::ConnectionFailed, ::Faraday::Error::TimeoutError]
          end
        end
      end
    end
  end
end
