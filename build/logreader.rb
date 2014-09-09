require 'openssl'
require 'digest/sha1'
require 'base64'

class LogReader

	def self.decryptor(encrypted_msg_64, token)
		# Decode from base64 then decrypt
		encrypted_msg = Base64.decode64(encrypted_msg_64)
		cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
		cipher.decrypt
		cipher.key = Digest::SHA1.hexdigest(token)

		decrypted = cipher.update(encrypted_msg) + cipher.final
		return decrypted
	end

	def self.state(lines)
		i = 0
		while lines[i]
			if /-E, (?<employee> [a-zA-Z]+)(.)*, -A, -R, (?<room> (\d)*)/ =~ lines[i]

			elsif /-E, (?<employee> [a-zA-Z]+)(.)*, -A, -R, (?<room> (\d)*)/ =~ lines[i]

			if /-E, (?<employee> [a-zA-Z]+)(.)*, -D, -R, (?<room> (\d)*)/ =~ lines[i]

			elsif /-E, (?<employee> [a-zA-Z]+)(.)*, -D, -R, (?<room> (\d)*)/ =~ lines[i]

			elsif /-E, (?<employee> [a-zA-Z]+)(.)*, -A/ =~ lines[i]
				employee_lines[i] = lines[i]
				# Associate employee name with most recent line referenced
				employee[Regexp.last_match(:employee)] = line
			elsif /-G, (?<guest> [a-zA-Z]+)(.)*, -A/ =~ lines[i]
				guest_lines[i] = lines[i]
				# Associate guest name with most recent line referenced
				guest_lines[Regexp.last_match(:guest)] = line
				guest_lines[i] = lines[i]
			else
				#TODO handle odd case
			end
			i = i + 1
		end
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

	# decrypt each line
	i = 0
	log.each_line { |line|
		decrypted_lines[i] = LogReader.decryptor(line, token)
	}
	
end

main

