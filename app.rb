require 'sinatra'
require 'sinatra/activerecord'
require 'pg'
require 'dotenv/load'
require 'omniauth'
require 'omniauth-github'
require 'json'
require './models/user'
require 'pry'
require 'jwt'
require 'rest-client'
require 'bootstrap'

if ENV['CLIENT_ID'] && ENV['CLIENT_SECRET']
  CLIENT_ID = ENV['CLIENT_ID']
  CLIENT_SECRET = ENV['CLIENT_SECRET']
else
  puts 'Sorry, there were no tokens!'
end

enable :sessions

configure do
  set :sessions, true
  set :inline_templates, true
end

use OmniAuth::Builder do
  provider :github, CLIENT_ID, CLIENT_SECRET
end

def private_session
  return erb :index unless token = session['user']
  hmac_secret = ENV['PASS']
  @data = JWT.decode token, hmac_secret, true, { :algorithm => ENV['ALG'] }
  erb "<pre>#{@data[0]["data"]}</pre>"
  return  unless data[0]["data"]
end

get '/' do
  erb :index
end

get '/users' do
  @users = User.all
  erb :users
end

post '/submit_user' do
  @user = User.new(params[:user])
  if @user.save
    redirect '/users'
  else
    "Sorry, there were an error!"
  end
end

get '/quest' do
  @levels = Level.all
  erb :quest
end
  
post '/submit-answer' do
  @user = User.new(params[:user])
  if @user.save
    redirect '/users'
  else
    "Sorry, there were an error!"
  end
end

get '/auth/:provider/callback' do
  private_session
  if request.env['omniauth.auth'][:info][:name] != nil then
    @user_name = request.env['omniauth.auth'][:info][:name] 
  else 
    @user_name = request.env['omniauth.auth'][:info][:nickname]
  end
  @user_id = request.env['omniauth.auth'][:uid]
  token = JWT.encode @user_id, hmac_secret, ENV['ALG']  
  erb "<h1 style='text-align:center;'>Hello, #{@user_name}</h1>"
end

get '/auth/failure' do
  erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
end

get '/auth/:provider/deauthorized' do
  erb "#{params[:provider]} has deauthorized this app."
end

get '/protected' do
  throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
  erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
       <a href='/logout'>Logout</a>"
end

get '/logout' do
  session[:authenticated] = false
  redirect '/'
end