require '%LATCH%/latch_sdk/Latch'

APPID="%APPID%"
SECRET="%SECRET%"
ACCOUNTID="%ACCOUNTID%"
#Others operations
COMMENT="%COMMENT%"

begin
	l = Latch.new(APPID,SECRET)
	#puts l.status(ACCOUNTID).data
	res = l.operationStatus(ACCOUNTID,COMMENT).data
	state = res["operations"][COMMENT]["status"]
	if state == "on" 
		puts "ok"
	else
		exit 1
	end
rescue
	puts "latch"
end
