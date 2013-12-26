require "faraday"
require "faraday_middleware"
require "singleton"

module Bot2ch
  class Client
    include Singleton

    class << self
      def get(url, &block)
        client = Client.instance
        client.config(&block) if block_given?
        client.get(url).body.lines.map(&:chomp)
      end
    end

    def initialize
      @client = Faraday.new do |builder|
        builder.use Faraday::Response::SjisToUTF8
        builder.use FaradayMiddleware::FollowRedirects, limit: 3
        builder.use Faraday::Response::RaiseError
        builder.adapter :net_http
      end
    end

    def config(&block)
      @client.instance_eval(&block)
    end

    def get(url)
      @client.get(url)
    end
  end
end
