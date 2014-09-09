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

	def self.state(lines, html)
		i = 0
		gallary_employees = Array.new
		gallary_guests = Array.new
		rooms = Hash.new # linked to array of guests per room
		last_lines = Hash.new
		while lines[i] 
			if /(?<name>[a-zA-Z]+).*/ =~ lines[i]
				#find last lines person mentioned in
				last_lines[Regexp.last_match(:name)] = lines[i]
			end
			i = i + 1
		end
		
		puts last_lines

		i = 0
		last_lines.each { |person, last_line|
			if /(?<person_type>-[E|G]), (?<name>[a-zA-Z]+).*, (?<arrive_depart>-[A|D]), -R, (?<room>(\d)*)/ =~ last_line
				# Entering/Leaving room
				if Regexp.last_match(:arrive_depart) == "-A"
					# arriving to room
					room_num = Regexp.last_match[:room].to_i
					puts "#{name} in #{room_num}"
					if rooms[room_num] == nil
						#array of guests
						rooms[room_num] = Array.new
					end
					rooms[room_num].push(name)
				else
					# Departing room.
				end

				# add to list of employees in gallary.
				if Regexp.last_match(:person_type) == "-E"
					gallary_employees.push(name)
				elsif Regexp.last_match(:person_type) == "-G"
					gallary_guests.push(name)
				end
			elsif /(?<person_type>-[E|G]), (?<name>[a-zA-Z]+).*, (?<arrive_depart>-[A|D])/ =~ last_line
				# Entering/Leaving Gallary
				if Regexp.last_match(:arrive_depart) == "-A"
					if Regexp.last_match(:person_type) == "-E"
						gallary_employees.push(name)
					elsif Regexp.last_match(:person_type) == "-G"
						gallary_guests.push(name)
					end
				else
					#TODO might not need to handle since their leaving anyway
				end
			else
				puts "no match" #DEBUG
			end
			i = i + 1
		}



		if html
			puts "<html>"
			puts "<body>"
			puts "<table>"
			puts "<tr>"
			puts "	<th>Employee</th>"
			puts "	<th>Guests</th>"
			puts "</tr>"
			i = 0
			while (gallary_employees[i] || gallary_guests[i])
				puts "<tr>"
				if gallary_employees[i]
					puts "	<th>#{gallary_employees[i]}</th>"
				end
				if gallary_guests[i]
					puts "	<th>#{gallary_guests[i]}</th>"
				end
				puts "</tr>"
				i = i + 1
			end
			puts "</table>"
			puts "</body>"
			puts "</html>"

		else
			puts gallary_employees.sort.join(", ")
			puts gallary_guests.sort.join(", ")

			puts rooms

			rooms.sort.map { |room_num, person|
				puts "#{room_num}: #{person.sort.join(", ")}"
			}
		end

	end


end


def main
	logname = ""
	decrypted_lines = Hash.new
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
	if File.exists?(logname)
		log = File.open(logname)
		#puts "Success"
	else
		#TODO uncomment abort "invalid"
	end

	# decrypt each line
	i = 0
	log.each_line { |line|
		decrypted_lines[i] = LogReader.decryptor(line, token)
	}
	
end


# start
main

