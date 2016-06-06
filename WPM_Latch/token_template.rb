require_relative 'latch_sdk/Latch'
#require 'json'

if ARGV.size != 1
	puts "Only 1 parameter: token.rb <token>"
	exit
end

appid="%APPID%"
secret="%SECRET%"

begin
l = Latch.new(appid,secret)

response = l.pair(ARGV[0].to_s)
puts "#{response.data['accountId']}"
rescue
	exit 1
end
