### LATCH RUBY SDK ###


#### PREREQUISITES ####

* Ruby 1.9.3 or above.

* Read API documentation (https://latch.elevenpaths.com/www/developers/doc_api).

* To get the "Application ID" and "Secret", (fundamental values for integrating Latch in any application), it’s necessary to register a developer account in Latch's website: https://latch.elevenpaths.com. On the upper right side, click on "Developer area".


#### USING THE SDK IN RUBY ####

* Require "Latch". Keep in mind where the SDK is placed inside your folder structure.
```
	require_relative '/latch/Latch'
```

* Create a Latch object with the "Application ID" and "Secret" previously obtained.
```
	api = Latch.new(appid, app_secret)
```

* Call to Latch Server. Pairing will return an account id that you should store for future api calls
```
     pairResponse = api.pair(PAIRING_CODE_HERE)
     statusResponse = api.status(ACCOUNT_ID_HERE)
     unpairResponse = api.unpair(ACCOUNT_ID_HERE)
```

* After every API call, get Latch response data and errors and handle them.
```
	responseData = response.data
	responseError = response.error
  ```
