class AmygdalaController < ApplicationController
  
  def index
    logger.debug request.inspect
    render :text => ""
  end
  
end
