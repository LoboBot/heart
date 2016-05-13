#UGLY AND DIRTY CODE BONJOUR

ENV['RACK_ENV'] ||= 'development'
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'sinatra'
require 'json'
require 'octokit'
require 'pp' # for pretty print debugging
require 'dotenv'
Dotenv.load

ACCESS_TOKEN = ENV['GITHUB_ACCESS_TOKEN']
SECRET_TOKEN = ENV['SECRET_TOKEN']

before do
  @client ||= Octokit::Client.new(:access_token => ACCESS_TOKEN)
end

def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),SECRET_TOKEN, payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end

get '/test' do
  "SECRET_TOKEN #{SECRET_TOKEN}"
end

post '/event_handler' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
  @payload = JSON.parse(payload_body)
  case request.env['HTTP_X_GITHUB_EVENT']
  when "pull_request"
    if @payload["action"] == "opened"
      process_pull_request(@payload["pull_request"] , @payload["repository"])
    else
      closed_pull_request(@payload["pull_request"] , @payload["repository"])
    end
  end
end

helpers do
  def process_pull_request(pull_request,repo)
    number = pull_request['number']
    repo_name = repo["name"]
    puts "checkvalidation #{repo_name}"
    case repo_name
    when "mirada"
      dir_git = "/Users/Michelin/Documents/Coding/LordAlexWorks/Clients/stefanka/Mirada/"
      system("./checkout_locally.sh #{dir_git} #{number}")
    end
  #  @client.create_status(pull_request['base']['repo']['full_name'], pull_request['head']['sha'], 'success')
  #  puts "Pull request processed!"
  end

  def closed_pull_request(pull_request,repo)
    number = pull_request['number']
    repo_name = repo["name"]
    puts "deploy #{repo_name}"
    case repo_name
    when "mirada"
      dir_git = "/Users/Michelin/Documents/Coding/LordAlexWorks/Clients/stefanka/Mirada/"
      system("./deploy.sh #{dir_git}")
    when "guava.android"
      dir_git = "/Users/Michelin/Documents/Coding/LordAlexWorks/us/android.guava/AndroidSource/GuavaAndroid"
      system("./deploy.sh #{dir_git}")
    end
  end
end
