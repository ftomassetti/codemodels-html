class ::String

	def first_index(sub)
		(0..(self.length-1)).each do |i|
			return i if self[i,sub.length].start_with?(sub)
		end
		nil
	end

	def last_index(sub)
		last = nil
		(0..(self.length-1)).each do |i|
			last=i if self[i,sub.length].start_with?(sub)
		end
		last
	end	

end