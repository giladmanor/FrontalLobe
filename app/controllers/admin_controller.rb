class AdminController < ApplicationController
  before_filter :request_filter
  before_filter :server_sais_filter
  skip_before_filter :request_filter, :only => [:login, :index]
  
  def login
    
    if params[:user]=="a" && params[:password]=="a"
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
        {:name=>'Social Sharing',:class=>"icon-glass",:action=>'/admin/social'},
        {:name=>'Top Ratings',:class=>"icon-heart",:action=>'/admin/rating'}
      ]}]
  end
  
end
