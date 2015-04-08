class Document < ActiveRecord::Base
  def initialize(params = {})
  	file = params.delete(:file)
  	super
  	if file
    	self.filename = sanitize_filename(file.original_filename)
    	self.content_type = file.content_type
    	self.file_contents = file.read
  	end
  end

  def parse
  	results = Array.new
  	version_results = Array.new

  	if self.file_contents.lines.grep(/newrelic_rpm/) != [] then version_results.push(self.file_contents.lines.grep(/newrelic_rpm/)) end
  	if self.file_contents.lines.grep(/escape_utils/) != [] then version_results.push(self.file_contents.lines.grep(/escape_utils/)) end
	if self.file_contents.lines.grep(/db-charmer/) != [] then version_results.push(self.file_contents.lines.grep(/db-charmer/)) end
 	if self.file_contents.lines.grep(/right_http_connection/) != [] then version_results.push(self.file_contents.lines.grep(/right_http_connection/)) end
  	if self.file_contents.lines.grep(/ar-octopus/) != [] then version_results.push(self.file_contents.lines.grep(/ar-octopus/)) end
  	if self.file_contents.lines.grep(/rocketpants/) != [] then version_results.push(self.file_contents.lines.grep(/rocketpants/)) end  	
   	if self.file_contents.lines.grep(/rails-api/) != [] then version_results.push(self.file_contents.lines.grep(/rails-api/)) end
  	if self.file_contents.lines.grep(/grape/) != [] && self.file_contents.lines.grep(/newrelic_rpm/)[0] < '3.10.0.279' then version_results.push(self.file_contents.lines.grep(/grape/)) end
  		
  	version_results.each do |f|
  		f[0] = f[0].match(/\((.*?)\)/)[1]
  		f[1] = f[1].chomp.lstrip
  	end
  	#return version_results
  	issues = YAML.load_file("#{Rails.root}/config/issues.yml")
    
    version_results.each do |f|
  			if issues.include?(f[1]) then results.push([f[1],issues[f[1]]]) end
  	end

  	return results

  end

private
  def sanitize_filename(filename)
    # Get only the filename, not the whole path (for IE)
    # Thanks to this article I just found for the tip: http://mattberther.com/2007/10/19/uploading-files-to-a-database-using-rails
    return File.basename(filename)
  end

  def self.check_for_issues

  end
end
