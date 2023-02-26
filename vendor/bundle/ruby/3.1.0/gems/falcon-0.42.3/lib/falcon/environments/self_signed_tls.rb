# frozen_string_literal: true

# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'localhost/authority'

# A self-signed SSL context environment.
#
# @scope Falcon Environments
# @name self_signed_tls
environment(:self_signed_tls) do
	# The default session identifier for the session cache.
	# @attribute [String]
	ssl_session_id {"falcon"}
	
	# The SSL context to use for incoming connections.
	# @attribute [OpenSSL::SSL::SSLContext]
	ssl_context do
		contexts = Localhost::Authority.fetch(authority)
		
		contexts.server_context.tap do |context|
			context.alpn_select_cb = lambda do |protocols|
				if protocols.include? "h2"
					return "h2"
				elsif protocols.include? "http/1.1"
					return "http/1.1"
				elsif protocols.include? "http/1.0"
					return "http/1.0"
				else
					return nil
				end
			end
			
			context.session_id_context = ssl_session_id
		end
	end
end
