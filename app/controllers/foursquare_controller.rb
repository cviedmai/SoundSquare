class FoursquareController < ApplicationController
  require 'json'
  before_filter :load_consumer, :only => :login

  def login
    username = params[:username] ? params[:username] : false
    password = params[:password] ? params[:password] : false
    if username and password
      res = @consumer.request(:post,'/v1/authexchange',nil,{},{"fs_username"=>username,"fs_password"=>password}).body
      doc =  REXML::Document.new res
      root = doc.root
      session[:oauth_token]  = root.elements["oauth_token"].text
      session[:oauth_token_secret] = root.elements["oauth_token_secret"].text
      redirect_to search_fs_path
    end
    #render :layout => false
    rescue
      flash[:error] = "Username or password incorrect"
      redirect_to login_fs_path
  end

  def addtrack
    venue_id = params[:venueid] ? params[:venueid] : 0
    track_id = params[:trackid] ? params[:trackid] : 0
    track_name = params[:trackname] ? params[:trackname] : 0
    s = Sound.find(:all, :conditions => ["venue = ? and track = ?", venue_id, track_id])
    if s.empty?
      #doesn't exist
      s = Sound.new(venue => venue_id, track => track_id, :title => track_name)
      s.save()
      render :layout => false, :partial => "removetrack"
    else
      s[0].delete
      render :layout => false, :partial => "addtrack"
    end    
  end
  
  def user

  end  

  def search
    lat = params[:lat] ? params[:lat] : false
    lng = params[:lng] ? params[:lng] : false
    q = params[:q] ? params[:q] : ""

    if !lat or !lng
      #Just load the page
    else
      #perform the search and return results
      @result = venue_search(q, lat, lng)
      render :partial => "search_result"
    end
  end

  def venue
    id = params[:id] ? params[:id] : 3474240
    @venue = venue_details(id)
    @sounds = Sound.find(:all, :conditions => {:venue => id})
    render :layout => false
  end

  def checkin
    @access_token = OAuth::AccessToken.new(@consumer, "access_key", "access_secret")
  end


  #  def create
#    request_token = @consumer.get_request_token(:oauth_callback => foursquare_auth_callback_url)
#  end

#  def callback
#    if session[:foursquare_request_token] && params[:oauth_token]
#      request_token = OAuth::RequestToken.new(@consumer, session[:foursquare_request_token], session[:foursquare_request_secret])
#      @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_token])
#      current_person.update_attributes(:foursquare_oauth_token => @access_token.token, :foursquare_oauth_secret => @access_token.secret)
#      flash[:notice] = "Foursquare! Yay!"
#      redirect_to edit_person_path(current_person)
#    else
#      redirect_to edit_person_path(current_person)
#    end
#  end


private

  def user_details
    create_access_token
    user_info = @access_token.get("http://api.foursquare.com/v1/user.json")
    JSON.parse(user_info.body)
  end

  def venue_search(query, lat, lng)
    create_access_token
    url = "http://api.foursquare.com/v1/venues.json?q=#{URI.escape(query)}&geolat=#{lat}&geolong=#{lng}"
    results = @access_token.get(url)
    response = JSON.parse(results.body)
  end

  def venue_details(id)
    create_access_token
    url = "http://api.foursquare.com/v1/venue.json?vid=#{id}"
    results = @access_token.get(url)
    response = JSON.parse(results.body)
  end

  def checkin(options)
    create_access_token
    response = @access_token.post("http://api.foursquare.com/v1/checkin.json", options)
    response = JSON.parse(response.body)
  end

  def tip(options)
    create_access_token
    response = @access_token.post("http://api.foursquare.com/v1/addtip", options)
  end

  def create_access_token
    load_consumer
    @access_token = OAuth::AccessToken.new(@consumer, session[:oauth_token], session[:oauth_token_secret])
  end

  def load_consumer
    @consumer = OAuth::Consumer.new(
      ENV["FS_CONSUMER_TOKEN"],
      ENV["FS_TOKEN_SECRET"], {
       :site               => "http://api.foursquare.com",
       :scheme             => :header,
       :http_method        => :post,
      })
  end

end
