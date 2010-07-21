# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require 'soundcloud'
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :logged_in?

  # Create a Soundcloud OAuth consumer token object
  consumer_token = ENV['SC_CONSUMER_TOKEN']
  consumer_secret = ENV['SC_CONSUMER_SECRET']
  sc_consumer = Soundcloud.consumer(consumer_token,consumer_secret)
  # Create an OAuth access token object
  access_token = OAuth::AccessToken.new(sc_consumer, consumer_token, consumer_secret)
  # Create an authenticated Soundcloud client, based on the access token
  $sc_client = Soundcloud.register({:access_token => access_token})


  def logged_in?
    false
  end

end
