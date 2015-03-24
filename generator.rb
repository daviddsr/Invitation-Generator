require 'sinatra'
require 'data_mapper'
require 'uuid'
require 'shotgun'
require 'pony'
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
  property :code, Text
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
  params[:users_invited].split(',').map do |guest|
    puts guest
    invitation = Invitation.create
    invitation.email = guest
    invitation.code = ('a'..'z').to_a.sample(4).join
    invitation.created_at = Time.now
    invitation.updated_at = Time.now
    invitation.event = event
    invitation.save
    invitation
  end
end

get '/' do
  @events = Event.all :order => :id.desc
  erb :home
end

post '/' do
  create_event.each do |invitation|
  Pony.mail({:to => invitation.email,
            :from => "daviddsrperiodismo@gmail",
            :subject => 'Confirm your invitation',
            :body => "Confirm your invitation at #{request.url}confirm/#{invitation.code}",
            :via => :smtp,
            :via_options => {
              :address              => 'smtp.gmail.com',
              :port                 => '587',
              :enable_starttls_auto => true,
              :user_name            => 'daviddsrperiodismo',
              :password             => '20041990',
              :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
              :domain               => "localhost" # the HELO domain provided by the client to the server
            }})
  end
  redirect '/'
end

get '/event/:id' do
  @event = Event.get params[:id]
  @confirmed = @event.invitations.count(:answer=>true)
  @rejected = @event.invitations.count(:answer=>false)
  erb :event
end

get '/confirm/:code' do
  invitation = Invitation.first(:code => params[:code]) 
  @event = Event.get invitation.event_id
  erb :invitation
end

put '/:code' do
  invitation = Invitation.first(:code => params[:code]) 
  p params[:answer]
  invitation.answer = params[:answer] == "Yes"
  invitation.save
end