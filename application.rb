[ "sinatra", "data_mapper", "dm-redis-adapter", "haml", "sass", "coffee-script", "geocoder",].each { |gem| require gem}

enable :inline_templates

DataMapper.setup(:default, {:adapter  => "redis"})

class Location
  include DataMapper::Resource
  property :id, Serial
  property :latitude, Float
  property :longitute, Float
  
  def address
    puts "I am an Address!"
  end
  
  def geocode
    puts "I am the geocoder!!!"
  end
  
  
end

get '/script.js' do
end

get '/' do
  haml :index
end

__END__

@@layout
= yield

@@index
%p Hello World