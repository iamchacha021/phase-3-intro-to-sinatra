# frozen_string_literal: true

# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'async/container/controller'

require_relative 'serve'
require_relative '../middleware/redirect'
require_relative '../service/proxy'

module Falcon
	module Controller
		# A controller for redirecting requests.
		class Redirect < Serve
			# Initialize the redirect controller.
			# @parameter command [Command::Redirect] The user-specified command-line options.
			def initialize(command, **options)
				super(command, **options)
				
				@hosts = {}
			end
			
			# Load the {Middleware::Redirect} application with the specified hosts.
			def load_app
				return Middleware::Redirect.new(Middleware::NotFound, @hosts, @command.redirect_endpoint)
			end
			
			# The name of the controller which is used for the process title.
			def name
				"Falcon Redirect Server"
			end
			
			# The endpoint the server will bind to.
			def endpoint
				@command.endpoint.with(
					reuse_address: true,
				)
			end
			
			# Builds a map of host redirections.
			def start
				configuration = @command.configuration
				
				services = Services.new(configuration)
				
				@hosts = {}
				
				services.each do |service|
					if service.is_a?(Service::Proxy)
						@hosts[service.authority] = service
					end
				end
				
				super
			end
		end
	end
end
