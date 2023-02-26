# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'digest/md5'

module Build
	class Environment
		def to_h
			hash = {}
			
			# Flatten this chain of environments:
			flatten_to_hash(hash)
			
			# Evaluate all items to their respective object value:
			evaluator = Evaluator.new(hash)
			
			# Evaluate all the individual environment values so that they are flat:
			Hash[hash.map{|key, value| [key, evaluator.object_value(value)]}]
		end
		
		def evaluator
			Evaluator.new(self)
		end
		
		def evaluate(**options)
			self.class.new(nil, self.to_h, **options)
		end
		
		def flatten(**options)
			hash = {}
			
			flatten_to_hash(hash)
			
			options[:name] ||= self.name
			
			return self.class.new(nil, hash, **options)
		end
		
		def defined
			@values.select{|name,value| Define === value}
		end
		
		def checksum(digester: Digest::SHA1.new)
			checksum_recursively(digester)
			
			return digester.hexdigest
		end
		
		protected
		
		def sorted_keys
			@values.keys.sort_by(&:to_s)
		end
		
		def checksum_recursively(digester)
			sorted_keys.each do |key|
				digester.update(key.to_s)
				
				case value = @values[key]
				when Proc
					digester.update(value.source_location.join)
				else
					digester.update(value.to_s)
				end
			end
			
			@parent.checksum_recursively(digester) if @parent
		end
		
		def update_hash(hash)
			@values.each do |key, value|
				previous = hash[key]
				
				if Replace === value
					# Replace the parent value
					hash[key] = value
				elsif Default === value
					# Update the parent value if not defined.
					hash[key] = previous || value
				elsif Array === previous
					# Merge with the parent value
					hash[key] = previous + Array(value)
				elsif OpenStruct === value
					hash[key] = value.to_h
				else
					hash[key] = value
				end
			end
			
			return self
		end
		
		# Apply the update function to this environment.
		def update!
			construct!(self, &@update)
			@update = nil
			
			return self
		end
		
		# We fold in the ancestors one at a time from oldest to youngest.
		def flatten_to_hash(hash)
			if parent = @parent
				parent = parent.flatten_to_hash(hash)
			end
			
			if @update
				self.dup(parent: parent).update!.update_hash(hash)
			else
				self.update_hash(hash)
			end
		end
	end
end
