require 'net/ssh'
require 'net/scp'

class Cloudler

	VERSION = '0.1.3'

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

	def self.precommands= precommands
		@precommands = precommands
	end

	def self.path= path
		@path = path
	end

	def self.run
		@files ||= []
		@gems ||= []
		@precommands ||= []
		@path ||= 
			if @username == 'root'
				'/root/.cloudler'
			else
				"/home/#{@username}/.cloudler"
			end

		@hosts.each do |host|
			Net::SSH.start(host, @username, :password => @password) do |ssh|
				puts "Uploading files..."
				ssh.exec! "rm -rf #{@path}"
				ssh.exec! "mkdir #{@path}"
				if @files.length > 0
	  			ssh.scp.upload!(@files.join(' '), @path, :recursive => true)
				else
					ssh.scp.upload!('.', @path, :recursive => true)
				end
				
				puts "Files uploaded."
	
				if @gems.length > 0 
					puts "Installing gems..."
					ssh.exec! "gem install #{@gems.join ' '}" do |ch, stream, data|
						puts data
					end
					puts "Gems installed"
				end
	
				if @precommands.length > 0
					puts "Executing pre-commands"
					@precommands.each do |command|
						ssh.exec "cd #{@path} && #{command}" do |ch,stream,data|
							puts data
						end
					end
					puts "Pre-commands executed."
				end

				puts "Executing command..."
				ssh.exec! "cd #{@path} && #{@command}" do |ch, stream, data|
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
path 'PATH' # Optional path to upload the files to. By default it is /root/.cloudler, or /home/[username]/.cloudler
precommands [] # Optional list of commands to run before executing the main command
command 'COMMAND'
files [] # Optional list of files to upload
gems [] # Optional list of gems to install
			EOS
		end
	end
end

def host hosts
	if hosts.is_a? Array
		Cloudler.hosts = hosts
	else
		Cloudler.hosts = [hosts]
	end
end

def username name
	Cloudler.username = name
end

def command string
	Cloudler.command = string
end

def gems array
	Cloudler.gems = array
end

def password pass
	Cloudler.password = pass
end

def files array
	Cloudler.files = array
end

def precommands array
	Cloudler.precommands = array
end

def path string
	Cloudler.path = string
end
