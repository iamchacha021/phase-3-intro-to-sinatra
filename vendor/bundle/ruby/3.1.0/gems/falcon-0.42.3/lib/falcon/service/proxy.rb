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

require_relative 'generic'

require 'async/http/endpoint'
require 'async/io/shared_endpoint'

module Falcon
	module Service
		class Proxy < Generic
			def name
				"#{self.class} for #{self.authority}"
			end
			
			# The host that this proxy will receive connections for.
			def authority
				@evaluator.authority
			end
			
			# The upstream endpoint that this proxy will connect to.
			def endpoint
				@evaluator.endpoint
			end
			
			# The {OpenSSL::SSL::SSLContext} that will be used for incoming connections.
			def ssl_context
				@evaluator.ssl_context
			end
			
			# The root
			def root
				@evaluator.root
			end
			
			# The protocol this proxy will use to talk to the upstream host.
			def protocol
				endpoint.protocol
			end
			
			# The scheme this proxy will use to talk to the upstream host.
			def scheme
				endpoint.scheme
			end
		end
	end
end
