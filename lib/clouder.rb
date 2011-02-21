require 'net/ssh'
require 'net/scp'

class Clouder
	def self.hosts= hosts
		@hosts = hosts
	end

	def self.username= username
		@username = username
	end

	def self.command= string
		@command = string
	end

	def self.gems= array
		@gems = array
	end

	def self.password= password
		@password = password
	end

	def self.files= files
		@files = files
	end

	def self.run
		@files ||= []
		@gems ||= []

		@hosts.each do |host|
			Net::SSH.start(host, @username, :password => @password) do |ssh|
				puts "Uploading files..."
				ssh.exec! "rm -rf /home/#{@username}/.clouder"
				ssh.exec! "mkdir /home/#{@username}/.clouder"
				if @files.length > 0
					ssh.scp.upload(@files.join(' '), "/home/#{@username}/.clouder", :recursive => true)
				else
	  			ssh.scp.upload!('.', "/home/#{@username}/.clouder", :recursive => true)
				end
	
				puts "Files uploaded."
	
				if @gems.length > 0 
					puts "Installing gems..."
					ssh.exec! "gem install #{@gems.join ' '}" do |ch, stream, data|
						puts data
					end
					puts "Gems installed"
				end
	
				puts "Executing command..."
				ssh.exec! "cd /home/#{@username}/.clouder && #{@command}" do |ch, stream, data|
					puts data
				end
				puts "Command finished."
			end
		end
	end

	def self.init
		File.open "Cloudfile", 'w' do |f|
			f.write <<-EOS
host 'HOSTNAME' # or for multiple servers, use ['HOST1', 'HOST2', ...]
username 'USERNAME'
password 'PASSWORD'
command 'COMMAND'
files [] # Optional list of files to upload
gems [] # Optional list of gems to install
			EOS
		end
	end
end

def host hosts
	if hosts.is_a? Array
		Clouder.hosts = hosts
	else
		Clouder.hosts = [hosts]
	end
end

def username name
	Clouder.username = name
end

def command string
	Clouder.command = string
end

def gems array
	Clouder.gems = array
end

def password pass
	Clouder.password = pass
end

def files array
	Clouder.files = array
end
