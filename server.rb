ENV['RACK_ENV'] ||= 'development'
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'sinatra'
require 'json'
require 'octokit'
require 'pp' # for pretty print debugging
require 'dotenv'
require 'yaml'
Dotenv.load
require 'yaml'


ACCESS_TOKEN = ENV['GITHUB_ACCESS_TOKEN']
SECRET_TOKEN = ENV['SECRET_TOKEN']

before do
  @client ||= Octokit::Client.new(:access_token => ACCESS_TOKEN)
  @repos = YAML.load_file('repos.yml')
end

def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),SECRET_TOKEN, payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end


get "/hello" do
  @repos = YAML.load_file('repos.yml')
  repo = @repos.fetch("mirada")
  p repo['type']
end

post '/event_handler' do

  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
  @payload = JSON.parse(payload_body)

  case request.env['HTTP_X_GITHUB_EVENT']
  when "pull_request"

    set_repo(repo["name"])
    @number = pull_request['number']

    if @payload["action"] == "opened"
      process_pull_request(@payload["pull_request"] , @payload["repository"])
    else
      closed_pull_request(@payload["pull_request"] , @payload["repository"])
    end

  end
end

helpers do
  def process_pull_request(pull_request)
    case @repo.type
    when "ios"
      system("./review_#{type}_pr.sh #{@local_path} #{number}")
    end
  #  @client.create_status(pull_request['base']['repo']['full_name'], pull_request['head']['sha'], 'success')
  #  puts "Pull request processed!"
  end

  def closed_pull_request(pull_request)
    case @repo.type
    when ios,android
      system("./deploy_mobile.sh #{@local_path}")
    end
  end

  def set_repo(name)
    @repo = @repos.fetch("#{name}")
    @local_path = @repo['local_path']
    @type = @repo['type']
  end
end
