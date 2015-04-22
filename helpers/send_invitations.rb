require 'pony'

module SendInvitations
  class << self
    attr_accessor :smtp_address, :smtp_port, :smtp_username, :smtp_password

    def send_invitations(invitation, url)
      Pony.mail({:to => invitation.email,
                :from => "daviddsrperiodismo@gmail",
                :subject => 'Confirm your invitation',
                :body => "Confirm your invitation at #{url}confirm/#{invitation.code}",
                :via => :smtp,
                :via_options => {
                  :address              => 'smtp_address',
                  :port                 => 'smtp_port',
                  :enable_starttls_auto => true,
                  :user_name            => 'smtp_username',
                  :password             => 'smtp_password',
                  :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
                  :domain               => "localhost" # the HELO domain provided by the client to the server
                }})
    end
  end
end