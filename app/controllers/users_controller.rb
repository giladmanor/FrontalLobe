class UsersController < AdminController
  before_filter :request_filter
  
  
  def index
    @users = User.all(params[:query]) || []
    logger.debug @users.inspect
  end
  
  def load
    @user = User.load params[:id]
  end
  
  def set
    User.set({:id=>pramas[:id],:email_address=>params[:email],:password=>params[:password]})
    redirect_to :action=>:load,:id=>params[:id] 
  end
  
  def surrogate
    redirect_to "http://dev.wikibrains.com/mishtamshim/use_token?token=#{User.get_token(params[:id])}"
  end
  
  def top_scribblers
    @scribblers = Event.top(100,"browser.create_scribble")
    logger.debug @scribblers.inspect 
    users = User.get_names_of(@scribblers.map{|u| u[:id]}.to_json)
    logger.debug users.inspect
    @scribblers.map!{|u| u.merge!(users[u[:id].to_s] ) unless users[u[:id]].nil?}
    
    logger.debug "|||||||||||||||||||||||||||||||||||||||||||||||||||"
    logger.debug @scribblers.inspect 
    logger.debug "|||||||||||||||||||||||||||||||||||||||||||||||||||"
    #@active =  Event.top(100,"%")
    #@gluers = Event.top(10,"browser.create_scribble")
  end
  
  def top_active
    @active =  Event.top(100,"%")
    users = User.get_names_of(@active.map{|u| u[:id]}.to_json)
    @active.map{|u| u.merge(users[u[:id]]) unless users[u[:id]].nil?}
  end
  
end
