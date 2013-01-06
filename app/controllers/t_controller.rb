class TController < ApplicationController
  def t
    e=Event.new
    e.user_id=params[:id]
    e.page_name=params[:p]
    e.word=params[:w]
    e.save
    render :text=>"//"
  end
  
end
