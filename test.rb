require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
require 'yaml'
Settings = YAML.load_file('settings.yml')
#DOCS
# http://www.twilio.com/docs/quickstart/ruby/devenvironment
# https://www.twilio.com/docs/quickstart/ruby/client/outgoing-calls
# https://www.twilio.com/docs/quickstart/ruby/rest/call-request
# put your default Twilio Client name here, for when a phone number isn't given
# https://www.twilio.com/docs/errors
default_client = "steve"

get '/' do
    # Find these values at twilio.com/user/account
    account_sid = Settings["account_sid"]
    auth_token = Settings["auth_token"]
    capability = Twilio::Util::Capability.new account_sid, auth_token
    # Create an application sid at twilio.com/user/account/apps and use it here
    capability.allow_client_outgoing Settings["app_sid"]
    capability.allow_client_incoming default_client
    token = capability.generate
    erb :index, :locals => {:token => token}
end

# Add a Twilio phone number or number verified with Twilio as the caller ID
caller_id = Settings["caller_id"]

post '/voice' do
    number = params[:PhoneNumber]

    response = Twilio::TwiML::Response.new do |r|
        # Should be your Twilio Number or a verified Caller ID
        r.Dial :callerId => caller_id do |d|
            # Test to see if the PhoneNumber is a number, or a Client ID. In
            # this case, we detect a Client ID by the presence of non-numbers
            # in the PhoneNumber parameter.
            if /^[\d\+\-\(\) ]+$/.match(number)
                puts d.Number(CGI::escapeHTML number)
                d.Number(CGI::escapeHTML number)
            else
                puts d.Client default_client
                d.Client default_client
            end
        end
    end
    response.text
end
