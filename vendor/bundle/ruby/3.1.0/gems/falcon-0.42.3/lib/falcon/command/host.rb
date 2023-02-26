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

require_relative '../controller/host'
require_relative '../configuration'
require_relative '../version'

require 'samovar'
require 'bundler'

module Falcon
	module Command
		# Implements the `falcon host` command. Designed for *deployment*.
		#
		# Manages a {Controller::Host} instance which is responsible for running applications in a production environment.
		class Host < Samovar::Command
			self.description = "Host the specified applications."
			
			# One or more paths to the configuration files.
			# @name paths
			# @attribute [Array(String)]
			many :paths, "Service configuration paths.", default: ["falcon.rb"]
			
			# The container class to use.
			def container_class
				Async::Container.best_container_class
			end
			
			# Generate a configuration based on the specified {paths}.
			def configuration
				configuration = Configuration.new
				
				@paths.each do |path|
					path = File.expand_path(path)
					configuration.load_file(path)
				end
				
				return configuration
			end
			
			# Prepare a new controller for the command.
			def controller
				Controller::Host.new(self)
			end
			
			# Prepare the environment and run the controller.
			def call
				Console.logger.info(self) do |buffer|
					buffer.puts "Falcon Host v#{VERSION} taking flight!"
					buffer.puts "- Configuration: #{@paths.join(', ')}"
					buffer.puts "- To terminate: Ctrl-C or kill #{Process.pid}"
					buffer.puts "- To reload: kill -HUP #{Process.pid}"
				end
				
				begin
					Bundler.require(:preload)
				rescue Bundler::GemfileNotFound
					# Ignore.
				end
				
				if GC.respond_to?(:compact)
					GC.compact
				end
				
				self.controller.run
			end
		end
	end
end
