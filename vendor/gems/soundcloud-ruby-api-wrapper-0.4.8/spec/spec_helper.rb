require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))


require 'soundcloud'

Spec::Runner.configure do |config|
  
end

def soundcloud_site
  'http://api.sandbox-soundcloud.com'
end

def soundcloud_settings
  return  {
          :access_token => 'your_access_token_here', 
          :access_secret => 'your_access_secret_here',
          :consumer_token => 'your_consumer_token_here',
          :consumer_secret => 'your_consumer_secret_here', 
          :bad_consumer_token => '98ydfg',
          :bad_consumer_secret => 'Sp9p1FTU0hhLBNXY'
          }
end

def valid_oauth_access_token
  access_token = soundcloud_settings[:access_token]
  access_secret = soundcloud_settings[:access_secret]
  consumer_token = soundcloud_settings[:consumer_token]
  consumer_secret = soundcloud_settings[:consumer_secret]

  sc_consumer = Soundcloud.consumer(consumer_token,consumer_secret,soundcloud_site)
  return OAuth::AccessToken.new(sc_consumer, access_token, access_secret)
end

