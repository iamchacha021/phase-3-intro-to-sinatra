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

require_relative '../controller/redirect'
require_relative 'paths'

require 'samovar'

module Falcon
	module Command
		class Redirect < Samovar::Command
			self.description = "Redirect from insecure HTTP to secure HTTP."
			
			# The command line options.
			# @attribute [Samovar::Options]
			options do
				option '--bind <address>', "Bind to the given hostname/address", default: "http://[::]:80"
				option '--redirect <address>', "Redirect using this address as a template.", default: "https://[::]:443"
				
				option '-t/--timeout <duration>', "Specify the maximum time to wait for non-blocking operations.", type: Float, default: nil
			end
			
			# One or more paths to the configuration files.
			# @name paths
			# @attribute [Array(String)]
			many :paths
			
			include Paths
			
			# Prepare a new controller for the command.
			def controller
				Controller::Redirect.new(self)
			end
			
			# The container class to use.
			def container_class
				Async::Container.best_container_class
			end
			
			# Options for the container.
			# See {Controller::Serve#setup}.
			def container_options
				{}
			end
			
			# Prepare the environment and run the controller.
			def call
				Console.logger.info(self) do |buffer|
					buffer.puts "Falcon Redirect v#{VERSION} taking flight!"
					buffer.puts "- Binding to: #{@options[:bind]}"
					buffer.puts "- To terminate: Ctrl-C or kill #{Process.pid}"
					buffer.puts "- To reload: kill -HUP #{Process.pid}"
				end
				
				self.controller.run
			end
			
			# The endpoint to bind to.
			def endpoint(**options)
				Async::HTTP::Endpoint.parse(@options[:bind], timeout: @options[:timeout], **options)
			end
			
			# The template endpoint to redirect to.
			def redirect_endpoint(**options)
				Async::HTTP::Endpoint.parse(@options[:redirect], **options)
			end
		end
	end
end
