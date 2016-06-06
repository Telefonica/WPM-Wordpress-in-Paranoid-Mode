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

class Error

	attr_reader :code
	attr_reader :message

	# @param string json a Json representation of an error with "code" and "message" elements
	def initialize(json)
		if (json.is_a?(String))
			json = JSON.Parse(json)
		end

		if(json.has_key?("code")  && json.has_key?("message"))
			@code = json["code"]
			@message = json["message"]
		else
			puts "Error creating error object from string " + json
		end
    end

    # JSON representing the Error Object
    def to_json
		error =  {}
		error["code"] = @code
		error["message"] = @message
		error.to_json
	end
end
