class Event < ActiveRecord::Base
  #attr_accessible :page_name, :user_id, :word
  
  def self.top(size,action)
    all = Event.find(:all,:conditions=>["user_id is not null and user_action like ?",action]).map{|u| u.user_id}
    uniqu = all.uniq
    ordered = uniqu.sort{|a,b| all.count(b)<=>all.count(a)}
    ordered.take(size).map{|uid|{:id=>uid,:count=>all.count(uid)}}
  end
  
  
end
