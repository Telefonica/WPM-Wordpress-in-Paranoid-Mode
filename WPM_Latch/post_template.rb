require '%LATCH%/latch_sdk/Latch'
#require 'net/ssh'
#require 'rubygems'
#require_relative 'Comment_latches'

APPID="%APPID%"
SECRET="%SECRET%"
ACCOUNTID="%ACCOUNTID%"
#Others operations
POST="%POST%"

begin
	l = Latch.new(APPID,SECRET)
	#puts l.status(ACCOUNTID).data
	res = l.operationStatus(ACCOUNTID,POST).data
	state = res["operations"][POST]["status"]
	if state == "on" 
		puts "ok"
	else
		exit 1
	end
rescue
	puts "latch"
end
