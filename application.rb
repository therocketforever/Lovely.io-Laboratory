[ "sinatra", "mongoid", "haml", "sass", "coffee-script", "geocoder", "pry"].each { |gem| require gem}

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
  @locations = Location.all.entries
  haml :index
end

post '/addaddress' do
  Location.create( address: params[:address])
  redirect '/'
end

get '/:id/delete' do
  @location = Location.find(params[:id])
  haml :deleteaddress
end

delete '/:id' do
  Location.find(params[:id]).destroy
  redirect '/'
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
  %script{src: "/js/lovely/core-1.1.0.js", type: "text/javascript"}

@@index
%p Hello World, Here are some Addresses!
%ul
  - @locations.each do |location|
    %li 
      = location.address
      %br
      = location.coordinates
      %a{:href => "/#{location.id}/delete"} Remove
%br
= haml :addaddress
      
@@addaddress
%p Add a New Location  
%form{ :action => "/addaddress", :method => "post"}
  %p "This address must be something that can be looked up via Geocoder 'cause I have not yet implemented validations."
  %label{ :for => "address"} New Address:
  %input{ :type => "text", :name => "address"}
  %input{:type => "submit", :value => "Add"}
  
@@deleteaddress
%p Are you sure you want to remove this addres?
= @location.address
%form{ :action => "/#{@location.id}", :method => "post"}
  %input{ :type => "hidden", :name => "_method", :value => "delete"}
  %input{ :type => "submit", :value => "Yes"}
  %a{ :href => '/'} No