
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
    redirect_to "http://wikibrains.com/mishtamshim/use_token?token=#{User.get_token(params[:id])}"
  end
  
  def top_scribblers
    @items = get_scribblers
  end
  
  def top_scribblers_csv
    send_data get_scribblers.map{|u| "#{u["name"]},#{u["email"]}"}.join("\n"),:type => 'text/csv; charset=iso-8859-1; header=present',:disposition => "attachment; filename=users.csv" 
     
  end
  
  def get_scribblers
    scribblers = Event.top(100,"browser.create_scribble")
    users = User.get_names_of(scribblers.map{|u| u[:id]}.to_json)
    scribblers.map{|u| u.merge!(users[u[:id].to_s] )}
  end
  
  def top_active
    @items = get_active
  end
  
  def top_active_csv
    send_data get_active.map{|u| "#{u["name"]},#{u["email"]}"}.join("\n"),:type => 'text/csv; charset=iso-8859-1; header=present',:disposition => "attachment; filename=users.csv"
  end
  
  
  def get_active
    active =  Event.top(100,"%")
    users = User.get_names_of(active.map{|u| u[:id]}.to_json)
    active.map{|u| u.merge!(users[u[:id].to_s] ) unless users[u[:id].to_s].nil?}.compact
  end
  
  
  
end
