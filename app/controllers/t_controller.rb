class TController < ApplicationController
  def t
    e=Event.new
    e.user_id=params[:u]
    e.page_name=params[:p]
    e.word=params[:w]
    e.ip = request.remote_ip
    e.user_action = params[:a]
    e.content_source = params[:cs]
    e.save
    Rails.cache.write("live_users",e.user_id,:expires_in => 1.minute)
    render :text=>"//"
  end
  
end
