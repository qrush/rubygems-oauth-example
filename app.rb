# https://github.com/ephekt/gmail-oauth2-sinatra/blob/master/app.rb

require 'sinatra'
require 'oauth2'
require 'json'

enable :sessions

def client
  OAuth2::Client.new(ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"], site: "http://rubygems.dev")
end

get '/' do
  erb :index
end

get "/auth" do
  redirect client.auth_code.authorize_url(redirect_uri: redirect_uri)
end

get "/callback" do
  access_token = client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
  session[:access_token] = access_token.token
  @message = "Successfully authenticated with the server"
  @access_token = session[:access_token]

  # intelligently try and parse the response.body
  #@email = access_token.get('https://www.googleapis.com/userinfo/email?alt=json').parsed
  erb :success
end


def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/callback'
  uri.query = nil
  uri.to_s
end
