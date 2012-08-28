[ "sinatra", "mongoid", "haml", "sass", "coffee-script", "geocoder",].each { |gem| require gem}

enable :inline_templates

Mongoid.load!("mongoid.yml")
Mongoid.logger.level = Logger::DEBUG
Mongoid.logger = Logger.new($stdout)

Geocoder.configure.timeout = 10

# This is a basic class to set up a location. The intention is that particular location types would be setup by subclassing this Location class. 

class Location
  include Mongoid::Document
  field :addressable
  field :coordinates, type: Array
  field :city
  field :state
  field :postal_code
  
# Location::address=() sets the value of self.addressable & passes this value to self.geocode as the encodeing argument
  def address=(query)
    self.addressable = query unless self.addressable
    self.geocode
  end
  
# Location::address returns the value of self.addressable
  def address
    self.addressable
  end
  
# Location::geocode() querys the Geocoder::search method, sets the value of location to the returned result & sets the various properties of the particular instance of Location to the corrisponding values. location.address is set to location.addressable to preserve the namespace for Location::address=() & Location::address.
  def geocode( query = self.addressable )
    location = Geocoder.search( query ).pop
    self.coordinates = location.coordinates
    self.addressable = location.address
    self.city = location.city
    self.state = location.state
    self.postal_code = location.postal_code
  end
end

get '/script.js' do
  content_type "text/javascript", :charset => 'utf-8'
  coffee :script
end

get '/' do
  haml :index
end

__END__

@@layout
!!! 5
%html
  %head
    -#%script{src="http://cdn.lovely.io/core.js"}
    
    %script{src: "/script.js"}
%body
  = yield

@@index
%p Hello World