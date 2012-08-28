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
  
# `Location::address=()` sets the value of `self.addressable` & passes this value to `self.geocode` as the encodeing argument
  def address=(query)
    self.addressable = query unless self.addressable
    self.geocode
  end
  
# `Location::address` returns the value of `self.addressable`
  def address
    self.addressable
  end
  
# `Location::geocode()` querys the `Geocoder::search` method, sets the value of location to the returned result & sets the various properties of the particular instance of Location to the corrisponding values. `location.address` is set to `location.addressable` to preserve the namespace for `Location::address=()` & `Location::address.`
  def geocode( query = self.addressable )
    location = Geocoder.search( query ).pop
    self.coordinates = location.coordinates
    self.addressable = location.address
    self.city = location.city
    self.state = location.state
    self.postal_code = location.postal_code
  end
end

# Various links to redirect browser requests to the appropriate file.
get '/script.js' do
  content_type "text/javascript", :charset => 'utf-8'
  coffee :script
end

# RESTful routes to define the structure of our application.
# This is the main index page it lists our address as well as provides a form to add a new address. The new address is persisted via Mondoid's `Location.create`.  
get '/' do
  @locations = Location.all.entries
  haml :index
end


# This is the post method for createing a new Location from the form on the index page
post '/addaddress' do
  Location.create( address: params[:address])
  redirect '/' unless request.xhr?
end

# This is the confermation page at the begining of the delete process. A `No` link is providet to return to the list on the index page. a `Yes` button is provided to submit a form wich will activate the delete route. 
get '/:id/delete' do
  @location = Location.find(params[:id])
  haml :deleteaddress
end

# This route is activated by the `Yes` form on the delete confermation page. The Location record will be queried & destroyed by it's `_ID` value.
delete '/:id' do
  Location.find(params[:id]).destroy
  redirect '/' unless request.xhr?
end


# Here be HAML...
__END__
@@layout
!!! 5
%html
  %head
    -#%script{src="http://cdn.lovely.io/core.js"}
  %body
    = yield
  -#%script{src: "/js/lovely/core-1.1.0.js", type: "text/javascript"}
  %script{src: "/js/right/right.js", type: "text/javascript"}
  %script{src: "/script.js"}
  %script{src: "/js/wump.js", type:"text/javascript"}
  
@@index
%h1 Hello World, Here are some Addresses!
%ul{ :id => "addresses"}
  - @locations.each do |location|
    %div{ :id => "#{location.id}"}
      %li 
        = location.address
        %br
        = location.coordinates
        %a{ :class => "remove", :href => "/#{location.id}/delete"} Remove
%br
= haml :addaddress
      
@@addaddress
%h2 Add a New Location  
%form{ :id => "addaddress", :action => "/addaddress", :method => "post"}
  %p "This address must be something that can be looked up via Geocoder 'cause I have not yet implemented validations."
  %label{ :for => "address"} New Address:
  %input{ :type => "text", :name => "address"}
  %input{:type => "submit", :value => "Add"}
  
@@deleteaddress
%p Are you sure you want to remove this addres?
= @location.address
%form{ :id => "deleteaddress", :action => "/#{@location.id}", :method => "post"}
  %input{ :type => "hidden", :name => "_method", :value => "delete"}
  %input{ :type => "submit", :value => "Yes"}
  %a{ :href => '/'} No