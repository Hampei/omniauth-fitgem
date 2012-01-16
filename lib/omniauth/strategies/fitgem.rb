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
        {
          :nickname => raw_info['screen_name'],
          :name => raw_info['name'],
          :location => raw_info['location'],
          :image => raw_info['profile_image_url'],
          :description => raw_info['description'],
          :urls => {
            'Website' => raw_info['url'],
            'Weibo' => 'http://weibo.com/' + raw_info['id'].to_s
          }
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/account/verify_credentials.json').body)
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