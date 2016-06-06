require_relative 'latch_sdk/Latch'

if ARGV.size != 1
	puts "Only 1 parameter: operations.rb <name>"
	exit
end


appid="%APPID%"
secret="%SECRET%"

begin
l = Latch.new(appid,secret)

name = ARGV[0].to_s
response = l.createOperation(appid,name,"DISABLED","DISABLED")
puts "#{response.data['operationId']}"
rescue
	exit 1
end
