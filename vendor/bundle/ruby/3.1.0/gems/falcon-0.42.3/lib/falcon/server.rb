# frozen_string_literal: true

# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'async/http/server'

require 'protocol/http/middleware/builder'
require 'protocol/http/content_encoding'

require 'async/http/cache'

require_relative 'middleware/verbose'
require 'protocol/rack'

module Falcon
	# A server listening on a specific endpoint, hosting a specific middleware.
	class Server < Async::HTTP::Server
		# Wrap a rack application into a middleware suitable the server.
		# @parameter rack_app [Proc | Object] A rack application/middleware.
		# @parameter verbose [Boolean] Whether to add the {Verbose} middleware.
		# @parameter cache [Boolean] Whether to add the {Async::HTTP::Cache} middleware.
		def self.middleware(rack_app, verbose: false, cache: true)
			::Protocol::HTTP::Middleware.build do
				if verbose
					use Middleware::Verbose
				end
				
				if cache
					use Async::HTTP::Cache::General
				end
				
				use ::Protocol::HTTP::ContentEncoding
				use ::Protocol::Rack::Adapter
				
				run rack_app
			end
		end
	end
end
