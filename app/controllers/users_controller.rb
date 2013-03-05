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
  
  
end
