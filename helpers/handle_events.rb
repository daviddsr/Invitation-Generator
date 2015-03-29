require './helpers/send_invitations'

include SendInvitations

module HandleEvents

  def self.create_event(title, description, users_invited)
    event = Event.new
    event.title = title
    event.description = description
    event.date = Time.now
    event.created_at = Time.now
    event.updated_at = Time.now
    event.save
    p "The event is this"
    create_invitations(event, users_invited)
  end

  def self.create_invitations(event, users_invited)
    invitations_array = []
    users_invited.split(',').map do |guest|
      invitation = Invitation.create
      invitation.email = guest
      invitation.code = ('a'..'z').to_a.sample(4).join
      invitation.created_at = Time.now
      invitation.updated_at = Time.now
      invitation.event = event
      invitation.save
      invitations_array << invitation
    end
    invitations_array
  end

end