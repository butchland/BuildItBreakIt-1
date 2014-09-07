require 'openssl'
require 'digest/sha1'
require 'base64'

class LogAppender

	def self.open_file path
		#TODO go to path then open in that dir
		file_name = path
		if (!File.exists?(file_name))
			#TODO create
		end
		file = File.open(file_name)
		return file
	end

	def self.encryptor(msg, token)
		#convert to base64
		cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
		cipher.encrypt
		cipher.key = Digest::SHA1.hexdigest(token)

		encrypt = cipher.update(msg) + cipher.final

		return encrypt
	end

end


#if ARGV.length > 0 then
#	if ARGV[0] = "-B" then
#		file_reader ARGV[1]
#	end
#else
  #TODO
#end
