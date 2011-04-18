module Octopi
  class Gist < Base
    include HTTParty
    attr_accessor :description, :repo, :public, :created_at
    
    include Resource
    set_resource_name "tree"
    resource_path ":id" 
		create_path "/new"   
    
    def self.base_uri
      "http://gist.github.com/api/v1"
    end     

    def self.find(id)
      result = get("#{base_uri}/#{id}")
      # This returns an array of Gists, rather than a single record.
      new(result["gists"].first)
    end      

		def self.set_api()
			if Api.authenticated == false 
		  	Api.api = Octopi::GistAnonymousApi.instance  
				return Api.api.post(path_for(:create), data)
		  else       
			  login = Api.api.login 
			  token = Api.api.token
		  	Api.api = Octopi::GistAuthApi.instance   
		    Api.api.login = login
		    Api.api.token = token
		  end
		end

    def self.create(files_list, private_gist = false)
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
		
		def self.write(files, private_gist = false)   
			data = data(files,private_gist)   
			set_api
		  return Api.api.post(path_for(:create), data)     
		end
		
		def self.data(files, private_gist = false) 
			data = {}
	    files.each do |file|
	      i = data.size + 1
	      data["file_ext[gistfile#{i}]"]      = file[:extension] ? file[:extension] : '.txt'
	      data["file_name[gistfile#{i}]"]     = file[:filename]
	      data["file_contents[gistfile#{i}]"] = file[:input]
	    end   
	    data.merge(private_gist ? { 'action_button' => 'private' } : {}) 
		end
    
  end
end
