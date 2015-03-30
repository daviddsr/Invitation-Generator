require 'sinatra'
require 'data_mapper'
require 'uuid'
require 'shotgun'
require 'pony'
require './helpers/handle_events'
require './helpers/send_invitations'

include HandleEvents
include SendInvitations

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/generator.db")

class Event
	include DataMapper::Resource
	property :id, Serial
	property :title, Text#, :required => true
  property :date, Date#, :required => true
	property :description, Text#, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
  has n, :invitations
end

class Invitation
  include DataMapper::Resource
  property :id, Serial
  property :code, Text
  property :answer, Boolean, :default => false
  property :email, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  belongs_to :event
end


DataMapper.finalize.auto_upgrade!

get '/' do
  @events = Event.all :order => :id.desc
  erb :home
end

post '/' do
  url = request.url
  HandleEvents.create_event(params[:title], params[:description], params[:users_invited]).each do |invitation|
    SendInvitations.send_invitations(invitation, url)
  end
  redirect '/'
end

get '/edit/event/:id' do
  @event = Event.get params[:id]
  @emails_array = []
  @event.invitations.each do |invitation|
    @emails_array << invitation.email
  end
  @emails_array
  erb :edit
end

put '/edit/event/:id' do
  url = URI.join(request.url, "/").to_s
  event = Event.get params[:id]

  if HandleEvents.updated_invitations?(event, params[:users_invited])
    HandleEvents.update_event(params[:id], params[:title], params[:description], params[:date_event], params[:users_invited]).each do |invitation|
      SendInvitations.send_invitations(invitation, url)
    end
  else
    HandleEvents.update_event(params[:id], params[:title], params[:description], params[:date_event], params[:users_invited])
  end
  redirect '/'
end

get '/check/event/:id' do
  @event = Event.get params[:id]
  @confirmed = @event.invitations.count(:answer=>true)
  @rejected = @event.invitations.count(:answer=>false)
  erb :event
end

get '/delete/event/:id' do
  @event = Event.get params[:id]
  if @event
    erb :delete
  end
end

delete '/delete/event/:id' do
  event = Event.get params[:id]
  event.destroy
  redirect '/'
end

get '/confirm/:code' do
  invitation = Invitation.first(:code => params[:code])
  @event = Event.get invitation.event_id
  erb :invitation
end

put '/confirm/invitation/:code' do
  invitation = Invitation.first(:code => params[:code]) 
  invitation.answer = params[:answer] == "Yes"
  invitation.save
  redirect "/confirm/#{params[:code]}"
end