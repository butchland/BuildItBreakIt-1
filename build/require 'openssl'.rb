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

puts "running"
ARGV.each do |arg|
	puts "Argument: #{arg}"
end