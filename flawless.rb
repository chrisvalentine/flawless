#
# Proper Header will go here
#
#
#
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require 'haml'
require 'sinatra/reloader'

DataMapper::setup(:default,"sqlite3://#{Dir.pwd}/flawless.db")

set :views, File.dirname(__FILE__) + "/views"

class Date
  def first_of_month
    Date.new(year, month, 1)
  end
  
  def first_sunday_of_first_week
    first = first_of_month
    first - first.wday
  end
  
  def last_of_month
	Date.new(self.year, self.month + 1, 1) - 1
  end
  
  def last_saturday_of_last_week
    last = last_of_month
	last + (6 - last.wday)
  end  
end

class Array
         def in_groups_of(number, fill_with = nil)
           if fill_with == false
             collection = self
           else
             # size % number gives how many extra we have;
             # subtracting from number gives how many to add;
             # modulo number ensures we don't add group of just fill.
             padding = (number - size % number) % number
             collection = dup.concat([fill_with] * padding)
           end
 
           if block_given?
             collection.each_slice(number) { |slice| yield(slice) }
           else
             returning [] do |groups|
               collection.each_slice(number) { |group| groups << group }
             end
           end
         end
end

class Entry
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true
  property :description, String
  property :product, Text, :required => true
  property :product_version, Text 
  property :url, Text, :format => :url
  property :created_at, Time, :default => Time.now
  property :status, Integer, :default => 0

  #attr_accessor :score

end
DataMapper.finalize.auto_upgrade!

get '/' do
  @entries = Entry.all :order => :id.desc
  haml :index
end

post '/' do
  Entry.create(:title => params[:title], :description => params[:description], :url => params[:url], :product => params[:product], :product_version => params[:product_version])
  redirect back
end

get '/entry/:id' do
  haml :entry
end

get '/calendar' do
	@dates = (Date.today.first_sunday_of_first_week..Date.today.last_saturday_of_last_week)
	@month = Date.today.month
	haml :calendar
end
