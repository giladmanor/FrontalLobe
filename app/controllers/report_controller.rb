class TController < ApplicationController
  def t
    Aggregate.get_data_from_brain
    render :text=>"ok"
  end
  
end
