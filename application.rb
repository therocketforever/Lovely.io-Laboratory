[ "sinatra", "mongoid", "haml", "sass", "coffee-script", "geocoder",].each { |gem| require gem}

enable :inline_templates

Mongoid.load!("mongoid.yml")
Mongoid.logger.level = Logger::DEBUG
Mongoid.logger = Logger.new($stdout)

Geocoder.configure.timeout = 10

class Location
  include Mongoid::Document
  field :addressable
  field :coordinates, type: Array
  field :city
  field :state
  field :postal_code
  
  def address=(query)
    self.addressable = query unless self.addressable
    self.geocode
  end
  
  def address
    self.addressable
  end
  
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
end

get '/' do
  haml :index
end

__END__

@@layout
= yield

@@index
%p Hello World