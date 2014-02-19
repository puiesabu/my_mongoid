module MyMongoid
	module Attributes
		
		module Processing
  
  		# Process the provided attributes casting them to their proper values if a
      # field exists for them on the document. This will be limited to only the
      # attributes provided in the suppied +Hash+ so that no extra nil values get
      # put into the document's attributes.
      #
      # @example Process the attributes.
      #   person.process_attributes(:title => "sir", :age => 40)
      #
      # @param [ Hash ] attrs The attributes to set.
      #
      # @since 0.0.1
			def process_attributes(attrs = nil)
				#TODO
 			end

			private

		end
	end
end