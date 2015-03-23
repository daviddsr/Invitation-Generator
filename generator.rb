require 'sinatra'
require 'data_mapper'
require 'uuid'
require 'shotgun'
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/generator.db")

class Event
	include DataMapper::Resource
	property :id, Serial
	property :title, Text#, :required => true
  property :date, DateTime#, :required => true
	property :description, Text#, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
  # property :invitation, Text
  has n, :invitations
end

class Invitation
  include DataMapper::Resource
  property :id, Serial
  property :url, Text
  property :answer, Boolean, :default => false
  property :email, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  belongs_to :event
end


DataMapper.finalize.auto_upgrade!

def create_event
  event = Event.new
  event.title = params[:title]
  event.description = params[:description]
  # event.date = params[:date_event]
  event.date = Time.now
  event.created_at = Time.now
  event.updated_at = Time.now
  event.save
  create_invitations(event)
end

def create_invitations(event)
  puts params[:users_invited]
  params[:users_invited].split(',').each do |guest|
    puts guest
    invitation = Invitation.new
    invitation.url = "/#{event.id}/#{guest}"
    invitation.email = guest
    invitation.created_at = Time.now
    invitation.updated_at = Time.now
    invitation.event = event
    invitation.save
  end
end

get '/' do
  @events = Event.all :order => :id.desc
  erb :home
end

post '/' do
  create_event

  redirect '/'
end

get '/:id' do
  @event = Event.get params[:id]
  erb :event
end