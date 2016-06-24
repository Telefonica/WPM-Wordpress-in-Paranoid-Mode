require '%LATCH%/latch_sdk/Latch'

APPID="%APPID%"
SECRET="%SECRET%"
ACCOUNTID="%ACCOUNTID%"
#Others operations
USERS="%USERS%"

begin
	l = Latch.new(APPID,SECRET)
	res = l.operationStatus(ACCOUNTID,USERS).data
	state = res["operations"][USERS]["status"]
	if state == "on" 
		puts "ok"
	else
		exit 1
	end
rescue
	puts "latch"
end
