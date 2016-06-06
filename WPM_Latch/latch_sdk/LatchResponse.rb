#Latch Ruby SDK - Set of  reusable classes to  allow developers integrate Latch on their applications.
#Copyright (C) 2013 Eleven Paths
#
#This library is free software; you can redistribute it and/or
#modify it under the terms of the GNU Lesser General Public
#License as published by the Free Software Foundation; either
#version 2.1 of the License, or (at your option) any later version.
#
#This library is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#Lesser General Public License for more details.
#
#You should have received a copy of the GNU Lesser General Public
#License along with this library; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


require 'rubygems'
require 'json'
require_relative 'Error'


# This class models a response from any of the endpoints in the Latch API.
# It consists of a "data" and an "error" elements. Although normally only one of them will be
# present, they are not mutually exclusive, since errors can be non fatal, and therefore a response
# could have valid information in the data field and at the same time inform of an error.
class LatchResponse

	attr_accessor :data
	attr_accessor :error


	# @param jsonString a json string received from one of the methods of the Latch API
	def initialize(jsonString)
		json = JSON.parse(jsonString)

		if(json != nil)
			if (json.has_key?("data"))
				@data = json["data"]
			end

			if (json.has_key?("error"))
				@error = Error.new(json["error"])
			end
		end
    end

    # Get JSON String that represents the LatchResponse object
	def to_json
		response = {}

		if (@data != nil)
			response["data"] = @data
		end

		if (@error != nil)
			response["error"] = @error.to_json
		end
		response.to_json
	end
end
