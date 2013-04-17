require 'net/http'
class User 
  
  
  def self.all(q)
    call("all",{:q=>q})
    
  end
  
  def self.load(id)
    call("get_user",{:id=>id}).merge(:last_action=>user_last_action(id))
  end
  
  def self.set(props)
    call("set_user",props)
  end
  
  def self.get_token(user_id)
    call("get_token",{:user_id=>user_id})
  end
  
  def self.top(size,entity, reference)
    call("get_top",{:entity=>entity, :reference=>reference})
  end
  
  def self.get_names_of(ids)
    call("get_names_for",{:ids=>ids})
  end
  
  private
  
  def self.user_last_action(user_id)
    res = Event.where(:user_id=>user_id).last
    res.created_at unless res.nil?
  end
  
  def self.call(meth,args={})
    uri = URI.parse("http://wikibrains.com/mishtamshim/#{meth}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    response = Net::HTTP.post_form(uri, args.merge(:k=>"fncsukfhbs8thsc8h3cncsl48ysl348cryl3v984tnlsxc48tp3wy984typq30489rupqw4ty957ty"))
    ActiveSupport::JSON.decode(response.body)
  end
  
end
