require 'pony'

module SendInvitations

def self.send_invitations(invitation, url)
  Pony.mail({:to => invitation.email,
            :from => "daviddsrperiodismo@gmail",
            :subject => 'Confirm your invitation',
            :body => "Confirm your invitation at #{url}confirm/#{invitation.code}",
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
end