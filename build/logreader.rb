require 'openssl'
require 'digest/sha1'
require 'base64'

class LogReader

	def self.decryptor(encrypted_msg, token)
		cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
		cipher.decrypt
		cipher.key = Digest::SHA1.hexdigest(token)

		decrypted = cipher.update(encrypted_msg) + cipher.final
		return decrypted
	end

end


def main
	log = ""
	i = 0
	while ARGV[i]
		if ARGV[i] == "-K"
			tokenre = /[a-z]*/ # temp token regex
			token = ARGV[i + 1]
			#TODO verification
			i = i + 1
		end
		if ARGV[i + 1] == nil
			logname = ARGV[i]
		end
		i = i + 1
	end
	if File.exists? logname
		log = File.open(logname)
		#puts "Success"
	else
		abort "invalid"
	end

	puts token

	log.each_line { |line|
		puts line
		LogReader.decryptor(line, token) #TODO remove
	}
	
end

main