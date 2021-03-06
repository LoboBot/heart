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
ROOT_DIRECTORY = ENV['ROOT_DICT']#TO

before do
  @client ||= Octokit::Client.new(access_token: ACCESS_TOKEN)
  @repos = YAML.load_file('repos.yml')
end

def verify_signature(payload_body)
  github_signature = request.env['HTTP_X_HUB_SIGNATURE']
  digest = OpenSSL::Digest.new('sha1')
  hexdig = 'sha1=' + OpenSSL::HMAC.hexdigest(digest, SECRET_TOKEN, payload_body)
  result_match = Rack::Utils.secure_compare(hexdig, github_signature)
  return halt 500, "Signatures didn't match!" unless result_match
end

post '/event_handler' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
  @payload = JSON.parse(payload_body)

  p "#{request.env['HTTP_X_GITHUB_EVENT']} - #{@payload['repository']['name']}"

  case request.env['HTTP_X_GITHUB_EVENT']
  when 'pull_request'
    p "STATE #{@payload["pull_request"]['state']}"
    repo(@payload['repository']['name'])
    @slug = @payload['repository']['full_name']
    @number = @payload["pull_request"]['number']
    state = @payload["pull_request"]['state']



    if state == 'open'
      open_pull_request
    else
      closed_pull_request
    end

  end
end

helpers do
  def open_pull_request
    Thread.start { system("./review_#{@type}1_pr.sh #{@local_path} #{@number} #{ACCESS_TOKEN} #{@slug} #{ROOT_DIRECTORY}")}
  end

  def closed_pull_request
    case @repo['type']
    when 'ios', 'android'
      Thread.start { system("./deploy_mobile.sh #{@local_path}") }
    end
  end

  def repo(name)
    @repo = @repos.fetch(name)
    @local_path = @repo['local_path']
    @type = @repo['type']
  end
end
