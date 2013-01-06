require 'net/http'
class Aggregate < ActiveRecord::Base
  attr_accessible :clues, :glues, :scribbles, :users
  
  
  def self.get_data_from_brain
    uri = URI.parse("http://wikibrains.com/bomba/ccmorfisdvmndjncasldkjcna")
    logger.debug "Accessing #{uri.host} #{uri.port} #{uri.request_uri}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    res = ActiveSupport::JSON.decode(response.body)
    logger.debug res["users"]
    
    log_entry(res)
    
  end
  
  def self.runner(range)
    
    range.each{|dd|
      date = dd.day.ago
      log_entry(data_by_date(date),date)
    }
    
  end
  
  def self.log_entry(res,ts=Time.now)
    logger.debug "==============================================================================="
    a = Aggregate.new
    a.users = res["users"]
    a.clues = res["clues"]
    a.glues = res["glues"]
    a.scribbles = res["scribbles"]
    a.timestamp = ts
    res = a.save
    logger.debug res
    logger.debug "==============================================================================="
  end
  
  def self.data_by_date(date)
    uri = URI.parse("http://wikibrains.com/bomba/krfiseurtksieurtbyoeu/#{date.strftime('%Y-%m-%d')}")
    logger.debug "Accessing #{uri.host} #{uri.port} #{uri.request_uri}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    return ActiveSupport::JSON.decode(response.body)
  end
  
end
