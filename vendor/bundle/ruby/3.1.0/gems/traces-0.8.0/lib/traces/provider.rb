# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'backend'

module Traces
	# @returns [Boolean] Whether there is an active backend.
	def self.enabled?
		self.const_defined?(:Backend)
	end
	
	module Provider
	end
	
	module Singleton
		# A module which contains tracing specific wrappers.
		def traces_provider
			@traces_provider ||= Module.new
		end
	end
	
	private_constant :Singleton
	
	# Bail out if there is no backend configured.
	if self.enabled?
		# Extend the specified class in order to emit traces.
		def self.Provider(klass, &block)
			klass.extend(Singleton)
			
			provider = klass.traces_provider
			provider.prepend(Backend::Interface)
			
			klass.prepend(provider)
			
			provider.module_exec(&block) if block_given?
			
			return provider
		end
	else
		def self.Provider(klass, &block)
			# Tracing disabled.
		end
	end
end
