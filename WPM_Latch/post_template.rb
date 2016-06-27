require '%LATCH%/latch_sdk/Latch'

APPID="%APPID%"
SECRET="%SECRET%"
ACCOUNTID="%ACCOUNTID%"
#Others operations
POST="%POST%"

begin
	l = Latch.new(APPID,SECRET)
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
