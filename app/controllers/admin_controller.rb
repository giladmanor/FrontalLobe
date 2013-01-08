class AdminController < ApplicationController
  before_filter :request_filter
  before_filter :server_sais_filter
  skip_before_filter :request_filter, :only => [:login, :index]
  
  def login
    
    if params[:user]=="jz" && params[:password]=="kcsd8bhvb85sdye8"
      session[:login]=:valid
      redirect_to :action=>:dashboard
      return
    end
    session[:login]=nil
    redirect_to :action=>:index, :server_sais=>'Bad Login attempt', :server_sais_type=>'error'
  end
  
  def logout
    session[:login]=nil
    redirect_to :action=>:index, :server_sais=>'User loged out', :server_sais_type=>'info'
  end
  
  def dashboard
    todays_agg = Aggregate.order("timestamp ASC").last
    yesterday = Aggregate.order("timestamp ASC").find(:all,:conditions=>["timestamp<?",1.day.ago]).last || {}
    last_week = Aggregate.order("timestamp ASC").find(:all,:conditions=>["timestamp<?",7.day.ago]).last || {}
    last_month = Aggregate.order("timestamp ASC").find(:all,:conditions=>["timestamp<?",1.month.ago]).last || {}
    
    @users = {
      :all=> todays_agg.users,
      :day=> todays_agg.users-yesterday.users,
      :week=>todays_agg.users-last_week.users,
      :month=>todays_agg.users-last_month.users
    } 
    @clues = {
      :all=>todays_agg.clues,
      :day=> todays_agg.clues-yesterday.clues,
      :week=>todays_agg.clues-last_week.clues,
      :month=>todays_agg.clues-last_month.clues
    } 
    @glues = {
      :all=>todays_agg.glues,
      :day=> todays_agg.glues-yesterday.glues,
      :week=>todays_agg.glues-last_week.glues,
      :month=>todays_agg.glues-last_month.glues
    } 
    @scribbles = {
      :all=>todays_agg.scribbles,
      :day=> todays_agg.scribbles-yesterday.scribbles,
      :week=>todays_agg.scribbles-last_week.scribbles,
      :month=>todays_agg.scribbles-last_month.scribbles
    } 
    
    
  end
  
  def graphs
    @from_d = params[:from_date].nil? ? 7.day.ago : Date.new(params[:from_date][:year].to_i,params[:from_date][:month].to_i,params[:from_date][:day].to_i)
    @to_d = params[:to_date].nil? ? Time.now : Date.new(params[:to_date][:year].to_i,params[:to_date][:month].to_i,params[:to_date][:day].to_i)
    
    
    from_a = Aggregate.order("timestamp ASC").find(:all,:conditions=>["timestamp<?",@from_d]).last || {}
    @to_a = Aggregate.order("timestamp ASC").find(:all,:conditions=>["timestamp<?",@to_d]).last || {}
    
    @users_total = @to_a.users
    @users = @to_a.users - from_a.users
    @clues = @to_a.clues - from_a.clues
    @glues = @to_a.glues - from_a.glues
    @scribbles = @to_a.scribbles - from_a.scribbles
    
  end
  
  def maps
    
    @lat = 0.0
    @lng = 0.0
    render :layout=>false
  end
  
  
  def trending
    uri = URI.parse("http://wikibrains.com/bomba/trending")
    logger.debug "Accessing #{uri.host} #{uri.port} #{uri.request_uri}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    @trending = ActiveSupport::JSON.decode(response.body)
    
  end
  
  def set_trending
    k="liebrubhvs984bsly48!35yf023985syv408l4ylst0w934ucy#as03495tvys0b*4tysa"
    #w=Rack::Utils.escape(params[:w])
    w=params[:w]
    logger.debug w
    r="set_trending_skd48bvk948vsy4lt8veyl4t8vxbl4t8y"
    #url="http://108.171.184.244/bomba/#{r}"
    url="http://wikibrains.com/bomba/#{r}"
    logger.debug url
    uri = URI.parse(url)
    logger.debug "Accessing #{uri.host} #{uri.port} #{uri.request_uri}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"k" => k, "w" => w.to_json})
    logger.debug w.to_json
    response = http.request(request)
    
    target = "trending.txt"
    File.open(target, "w+") do |f|
      f.write(params[:w].to_json)
    end
    redirect_to :action=>:trending
  end
  
  def index
    #redirect_to :action=>:login
    render :layout=>false
  end
  
  
  #############################################################################################################
  def say(type,message)
    return type,message
  end
  
  
  def server_sais_filter
    @server_sais = params[:server_sais]
    @server_sais_type = params[:server_sais_type]
    @page_name = params[:action].camelize 
    @section_name = params[:controller].camelize 
  end
  
  def request_filter
    logger.debug "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\n Request Filter #{params[:action]} From[#{request.remote_ip}]"
    
    if session[:login]!=:valid
      logger.warn "(!) Invalid session"
      redirect_to :action=> 'index', :server_sais=>'Please login before accessing Admin', :server_sais_type=>'warning' 
      return
    end
    
    @login_name = "Uncle Ruckus"
    @menu_items = [
      {:name=>'Main',:children=>[
        {:name=>'Dashboard',:class=>"icon-home",:action=>'/admin/dashboard'},
        {:name=>'Trending',:class=>"icon-glass",:action=>'/admin/trending'},
        {:name=>'Summary',:class=>"icon-glass",:action=>'/admin/graphs'},
        {:name=>'Map',:class=>"icon-heart",:action=>'/admin/maps'}
      ]}]
  end
  
end
