module Octopi
  # Gist API is... lacking at the moment.
  # This class serves only as a reminder to implement it later
  class Gist < Base
    include HTTParty
    attr_accessor :description, :repo, :public, :created_at
    
    include Resource
    set_resource_name "tree"
    resource_path ":id"
    
    def self.base_uri
      "https://gist.github.com/gists"
    end
    
    def self.find(id)
      result = get("#{base_uri}/#{id}")
      # This returns an array of Gists, rather than a single record.
      new(result["gists"].first)
    end 

    def self.new(files_list,private_gist=false)
		  files = []  
			files_list.each do |file|  
				files.push({
	        :input     => File.read(file),
	        :filename  => file,
	        :extension => (File.extname(file) if file.include?('.'))
	      })
			end 
			write(files, private_gist) 
		end     
		
		def self.write(files,private_gist=false)   
			data     = data(files,private_gist)
			response = Api.api.post('/', data)  
		end
		
		def self.data(files,private_gist=false) 
			data = {}
	    files.each do |file|
	      i = data.size + 1
	      data["file_ext[gistfile#{i}]"]      = file[:extension] ? file[:extension] : '.txt'
	      data["file_name[gistfile#{i}]"]     = file[:filename]
	      data["file_contents[gistfile#{i}]"] = file[:input]
	    end   
	    data.merge(private_gist ? { 'action_button' => 'private' } : {}) 
		end
    
    # def files
    #   gists_folder = File.join(ENV['HOME'], ".octopi", "gists")
    #   File.mkdir_p(gists_folder)
    #   `git clone git://`
    # end
  end
end
