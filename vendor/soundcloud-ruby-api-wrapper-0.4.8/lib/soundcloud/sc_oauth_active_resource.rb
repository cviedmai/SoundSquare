require 'rubygems'

gem 'activeresource'
require 'active_resource'
require 'digest/md5'
require File.expand_path('../public_oauth_access_token', __FILE__)

module SCOAuthActiveResource 
  
  # TODO check if klass has ancestor OAuthActiveResource
  def self.register(add_to_module, model_module, options = {})
      
    oauth_connection = options[:access_token]
    
    if oauth_connection.nil?
      oauth_connection = Soundcloud::PublicOAuthAccessToken.new(options[:consumer_key])
    end

    temp_hash = {:access_token => oauth_connection}
    options.merge!(temp_hash)

    mod = OAuthActiveResource.register(add_to_module, model_module, options)
    return mod
  end
  
end

require 'oauth_active_resource/connection'
require 'oauth_active_resource/resource'
require 'oauth_active_resource/unique_resource_array'
