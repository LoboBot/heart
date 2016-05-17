require 'octokit'

p "Comment pushed on giThub"

#TO DO
message = ARGV[3]
token = ARGV[0]
number_pl = ARGV[2]
slug = ARGV[1]

gitbu_client = Octokit::Client.new(access_token:token)

##find who create the  PR

gitbu_client.add_comment(slug,number_pl,message)
