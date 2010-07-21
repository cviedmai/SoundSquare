class SoundController < ApplicationController

  def hottest
    # Find the 10 hottest tracks
    @hot_tracks = $sc_client.Track.find(:all,:params => {:order => 'hotness', :limit => 10})
    render :layout => false
  end
    
  def search
    query = params[:query] ? params[:query] : false
    @venue = params[:venue] ? params[:venue] : false
    
    if query
      @tracks = $sc_client.Track.find(:all,:params => {:order => 'hotness',
          :limit => 10, :q => query})
      render :partial => "search_result"
    else
      #Renders the search form
      render :layout => false
    end
  end

  def track
    id = params[:id] ? params[:id] : 123
    @venue = params[:venue] ? params[:venue] : false
    @track = $sc_client.Track.find(id)
    render :layout => false
  end
end
