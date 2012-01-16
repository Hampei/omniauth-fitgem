require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Fitgem < OmniAuth::Strategies::OAuth
      option :name, 'fitgem'
      option :sign_in, true
      def initialize(*args)
        super
        options.client_options = {
          :access_token_path => '/oauth/access_token',
          :authorize_path => '/oauth/authorize',
          :realm => 'OmniAuth',
          :request_token_path => '/oauth/request_token',
          :site => 'http://api.fitbit.com',
        }
      end

      def consumer
        consumer = ::OAuth::Consumer.new(options.consumer_key, options.consumer_secret, options.client_options)
        consumer
      end

      uid { raw_info["id"] }

      info do
        @raw_info
      end

      extra do
        { :raw_info => raw_info }
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/1/user/-/profile.json').body)
        if @populated
          puts @raw_info.inspect
          puts
        end
        @populated = true
        @raw_info 
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end