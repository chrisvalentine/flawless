require 'sinatra'
require 'data_mapper'
require 'haml'
require 'sinatra/reloader'

DataMapper::setup(:default,"sqlite3://#{Dir.pwd}/flawless.db")

set :views, File.dirname(__FILE__) + "/views"

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
