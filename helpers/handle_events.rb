

module HandleEvents

  def self.create_event(title, description, users_invited)
    event = Event.new
    event.title = title
    event.description = description
    event.date = Time.now
    event.created_at = Time.now
    event.updated_at = Time.now
    event.save
    event
    create_invitations(event, users_invited)
  end

  def self.create_invitations(event, users_invited)
    invitations_array = []
    users_invited.split(',').map do |guest|
      invitations_array << build_invitation(guest, event)
    end
    invitations_array
  end

  def self.update_event(id, title, description, date_event, users_invited)
    event = Event.get id
    event.title = title
    event.description = description
    event.date = date_event
    event.updated_at = Time.now
    event.save
    event
    update_invitations(event, users_invited) if updated_invitations?(event, users_invited)     
  end

  def self.update_invitations(event, users_invited)
    invitations_array = []
    users_invited.split(',').map do |guest|
      unless invitation_exist?(event, guest)
      invitations_array << build_invitation(guest, event)
      end
    end
    invitations_array
  end

  def self.invitation_exist?(event, guest)
    emails_already_invited = event.invitations.map { |invitation| invitation.email}
    emails_already_invited.include?(guest)
  end

  def self.build_invitation(guest, event)
    invitation = Invitation.create
    invitation.email = guest
    invitation.code = ('a'..'z').to_a.sample(4).join
    invitation.created_at = Time.now
    invitation.updated_at = Time.now
    invitation.event = event
    invitation.save
    invitation
  end

  def self.updated_invitations?(event, users_invited)
    emails_already_invited = event.invitations.map { |invitation| invitation.email}
    p emails_already_invited
    p users_invited
    users_invited_array = users_invited.split(',')
    emails_already_invited.sort == users_invited_array.sort ? false : true
  end

end