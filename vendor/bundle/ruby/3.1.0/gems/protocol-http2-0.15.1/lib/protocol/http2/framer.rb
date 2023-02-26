# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require_relative 'error'

require_relative 'data_frame'
require_relative 'headers_frame'
require_relative 'priority_frame'
require_relative 'reset_stream_frame'
require_relative 'settings_frame'
require_relative 'push_promise_frame'
require_relative 'ping_frame'
require_relative 'goaway_frame'
require_relative 'window_update_frame'
require_relative 'continuation_frame'

module Protocol
	module HTTP2
		# HTTP/2 frame type mapping as defined by the spec
		FRAMES = [
			DataFrame,
			HeadersFrame,
			PriorityFrame,
			ResetStreamFrame,
			SettingsFrame,
			PushPromiseFrame,
			PingFrame,
			GoawayFrame,
			WindowUpdateFrame,
			ContinuationFrame,
		].freeze
		
		# Default connection "fast-fail" preamble string as defined by the spec.
		CONNECTION_PREFACE = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n".freeze
		
		class Framer
			def initialize(stream, frames = FRAMES)
				@stream = stream
				@frames = frames
			end
			
			def close
				@stream.close
			end
			
			def closed?
				@stream.closed?
			end
			
			def write_connection_preface
				@stream.write(CONNECTION_PREFACE)
			end
			
			def read_connection_preface
				string = @stream.read(CONNECTION_PREFACE.bytesize)
				
				unless string == CONNECTION_PREFACE
					raise HandshakeError, "Invalid connection preface: #{string.inspect}"
				end
				
				return string
			end
			
			# @return [Frame] the frame that has been read from the underlying IO.
			# @raise if the underlying IO fails for some reason.
			def read_frame(maximum_frame_size = MAXIMUM_ALLOWED_FRAME_SIZE)
				# Read the header:
				length, type, flags, stream_id = read_header
				
				# Async.logger.debug(self) {"read_frame: length=#{length} type=#{type} flags=#{flags} stream_id=#{stream_id} -> klass=#{@frames[type].inspect}"}
				
				# Allocate the frame:
				klass = @frames[type] || Frame
				frame = klass.new(stream_id, flags, type, length)
				
				# Read the payload:
				frame.read(@stream, maximum_frame_size)
				
				# Async.logger.debug(self, name: "read") {frame.inspect}
				
				return frame
			end
			
			def write_frame(frame)
				# Async.logger.debug(self, name: "write") {frame.inspect}
				
				frame.write(@stream)
				
				# Don't call @stream.flush here because it can cause significant contention if there is a semaphore around this method.
				# @stream.flush
				
				return frame
			end
			
			def read_header
				if buffer = @stream.read(9)
					if buffer.bytesize == 9
						return Frame.parse_header(buffer)
					end
				end
				
				raise EOFError, "Could not read frame header!"
			end
		end
	end
end
