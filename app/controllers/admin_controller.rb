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
    
    @data_serves = Event.all.size
    
  end
  
  def summary
    @from_d = params[:from_date].nil? ? 7.day.ago : Date.new(params[:from_date][:year].to_i,params[:from_date][:month].to_i,params[:from_date][:day].to_i)
    @to_d = params[:to_date].nil? ? Time.now : Date.new(params[:to_date][:year].to_i,params[:to_date][:month].to_i,params[:to_date][:day].to_i)
    
    
    @from_a = Aggregate.order("timestamp ASC").find(:all,:conditions=>["timestamp<?",@from_d]).last || {}
    @to_a = Aggregate.order("timestamp ASC").find(:all,:conditions=>["timestamp<?",@to_d]).last || {}
    
    @collection = Aggregate.order("timestamp ASC").find(:all,:conditions=>["timestamp>? and timestamp<?",@from_d,@to_d])
    logger.debug @collection.length 
    
    @users_total = @to_a.users
    @users = @to_a.users - @from_a.users
    @clues = @to_a.clues - @from_a.clues
    @glues = @to_a.glues - @from_a.glues
    @scribbles = @to_a.scribbles - @from_a.scribbles
    
  end
  
  def data_report
    @from_d = params[:from_date].nil? ? 7.day.ago : Date.new(params[:from_date][:year].to_i,params[:from_date][:month].to_i,params[:from_date][:day].to_i)
    @to_d = params[:to_date].nil? ? Time.now : Date.new(params[:to_date][:year].to_i,params[:to_date][:month].to_i,params[:to_date][:day].to_i)
    
    @collection = Event.find(:all,:conditions=>["created_at>? and created_at<?",@from_d,@to_d])
    logger.debug "Query resulted in #{@collection.size}"
    days = @to_d-@from_d 
    logger.debug "parse as #{days} days"
    @serves=[]
    @opens=[]
    @creation=[]
    
    if days < 100
      days.to_i.times{|i|
        events=@collection.select{|e| e.created_at<(@from_d+(i+1).days) && e.created_at>(@from_d+(i).days)}
        @serves<<events.size
        @opens<<events.select{|e| e.user_action=="browser.open_content"}.size
        @creation<<events.select{|e| e.user_action=="browser.create_scribble"}.size
        
      }
    else
      @serves=[0]
      @opens=[0]
      @creation=[0]
    end
    
    logger.debug "-- #{@serves.length} \n -- #{@serves.inspect}"
    
  end
  
  
  def stats
    
    @from_d = params[:from_date].nil? ? 7.day.ago : Date.new(params[:from_date][:year].to_i,params[:from_date][:month].to_i,params[:from_date][:day].to_i)
    @to_d = params[:to_date].nil? ? Time.now : Date.new(params[:to_date][:year].to_i,params[:to_date][:month].to_i,params[:to_date][:day].to_i)
    
    add_arr = ["browser.plus_clue","browser.add_clue"]
    
    @users = Event.find(:all,:conditions=>["created_at>? and created_at<?",@from_d,@to_d]).map{|e| e.user_id}.uniq.compact
    @events_per_user = @users.map{|u| 
      user_actions = Event.find(:all,:conditions=>["user_id=?",u]).map{|e| e.user_action}
      fi_plus= user_actions.index{|a| add_arr.include?(a) }
      brw_until_plus = user_actions.take(fi_plus).reject{|a| a=="browser.get_scribbles"} unless  fi_plus.nil?
      brw_until_plus.nil? ? nil : brw_until_plus.length
    }.compact
    
    @anonimouses = Event.find(:all,:conditions=>["created_at>? and created_at<? and user_id is null",@from_d,@to_d]).map{|e| e.ip}.uniq.compact
    @events_per_ip = @anonimouses.map{|u| 
      user_actions = Event.find(:all,:conditions=>["ip=?",u]).map{|e| e.user_action}
      fi_plus=user_actions.index{|a| add_arr.include?(a) }
      brw_until_plus = user_actions.take(fi_plus).reject{|a| a=="browser.get_scribbles"} unless  fi_plus.nil?
      brw_until_plus.nil? ? nil : brw_until_plus.length
    }.compact
  end
  
  
  def maps
    
    @lat = 0.0
    @lng = 0.0
    render :layout=>false
  end
  
  def data_serves
    last= params[:last].nil? ? 1.minute.ago : params[:last].to_i.minute.ago 
    res = Event.find(:all,:conditions=>["created_at>?",last]).size
    render :text=> res
    logger.debug "$$$$$$$$$$$$     #{res}"
  end
  
  def uniqe_users
    last= params[:last].nil? ? 1.minute.ago : params[:last].to_i.minute.ago 
    res = Event.find(:all,:conditions=>["created_at>? and user_id IS NOT NULL",last]).map{|e| e.user_id}.uniq.size
    render :text=> res
    logger.debug "$$$$$$$$$$$$     #{res}"
  end
  
  def anonimouse
    last= params[:last].nil? ? 1.minute.ago : params[:last].to_i.minute.ago 
    res = Event.find(:all,:conditions=>["created_at>? and user_id IS NULL",last],:group=>"ip").size
    render :text=> res
    logger.debug "$$$$$$$$$$$$     #{res}"
  end
  
  def sribbles
    last= params[:last].nil? ? 1.minute.ago : params[:last].to_i.minute.ago 
    res = Event.find(:all,:conditions=>["created_at>? and user_action=?",last,"browser.get_scribbles"]).size
    render :text=> res
    logger.debug "$$$$$$$$$$$$     #{res}"
  end
  
  def media_opens
    last= params[:last].nil? ? 1.minute.ago : params[:last].to_i.minute.ago 
    res = Event.find(:all,:conditions=>["created_at>? and user_action=?",last,"browser.open_content"]).size
    render :text=> res
    logger.debug "$$$$$$$$$$$$     #{res}"
  end
  
  def plussing
    last= params[:last].nil? ? 1.minute.ago : params[:last].to_i.minute.ago 
    res = Event.find(:all,:conditions=>["created_at>? and user_action=?",last,"browser.plus_clue"]).size
    render :text=> res
    logger.debug "$$$$$$$$$$$$     #{res}"
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
    w=params[:extra_values].split(",") + params[:w]
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
        {:name=>'Moderate Trending',:class=>"icon-glass",:action=>'/admin/trending'},
        {:name=>'Summary',:class=>"icon-glass",:action=>'/admin/summary'},
        {:name=>'Data Serves',:class=>"icon-glass",:action=>'/admin/data_report'},
        {:name=>'Usage',:class=>"icon-glass",:action=>'/admin/stats'},
        {:name=>'Map',:class=>"icon-heart",:action=>'/admin/maps'}
      ]}]
  end
  
end
