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

	#-------------------------------------------------------------------
	# 					Gonzalo's code
	#-------------------------------------------------------------------
	def initialize
		@flag_id = {'-T' => true, '-K' => true, '-G' => true, '-E' => true, \
      		        '-A' => true, '-L' => true, '-R' => true}
    	@log_line = []

	    @gallery = {}
	    @rooms = []
	    # @logged_in_employees = {}
	    # @logged_in_guests = {}
	    # read_logged_in_people()
  	end

	def valid_batch?(args)
		return true
	end

	def output_error()
		puts "invalid"
	    exit(-1)
	end

  #---------------------------------------------
  # process and validates arguments
  def process_line(args)
  	token = ""
    while args.size() > 1
      f_id = args.shift
      if @flag_id.has_key?(f_id)
        case f_id
          when '-T'
            time_stamp = args.shift
            if time_stamp !~ /^[0-9]+$/
              output_error
            end
            @log_line[0] = time_stamp
            # puts "processed -T, time: #{time_stamp}"
          when '-K'
            token = args.shift
            if token !~ /^([a-zA-Z0-9]+)$/
              output_error
            end
            # puts "processed -K, token: #{token}"
          when '-G', '-E'
            @flag_id.delete('-G')
            @flag_id.delete('-E')
            eg_name = args.shift
            if eg_name !~ /^([a-zA-Z]+)$/
              output_error
            end
            @log_line[1] = eg_name
            # puts "processed (-G|-E), name: #{eg_name}"
          when '-A', '-L'
            @flag_id.delete('-A')
            @flag_id.delete('-L')
            @log_line[2] = f_id
            # puts "processed (-A|-L), ad status: #{f_id}"
          when '-R'
            room_id = args.shift
            if room_id !~ /^([0-9]+)$/
              output_error
            end
            @log_line[3] = room_id
            # puts "processed (-G|-E), name: #{name}"
          else 
            output_error
        end
        @flag_id.delete(f_id)

      else
        output_error

      end

      # puts "#{args}"
      # puts "#{@flag_id}"
    end
    log_file = args.shift
    if log_file !~ /^(([a-zA-Z0-9_]+)|(\/[a-zA-Z0-9_]+)+)$/
      output_error
    end
      puts log_file

    if file_exists?(log_file)
      # append to it
      log_F = File.open(log_file, 'w')
      log_F.write(LogAppender.encryptor(@log_line.join,token))
    else
      # create new file

    end

    

    puts "#{@log_line}"
  end

  #---------------------------------------------
  # processes logs in a batch
  def process_batch()
    puts "processing batch"
  end

  

  #---------------------------------------------
  # Returns true if file exists, false otherwise
  def file_exists?(filename)
    return File.file?(filename)
  end

  #---------------------------------------------
  # Reads file
  def read_file(filename)

  end

end

#------------------------------------------------
# EXECUTABLE CODE
#------------------------------------------------
logger = LogAppender.new

# check # of command line arguments
if ARGV.length == 10 || ARGV.length == 8
	puts "running"
  logger.process_line(ARGV)

elsif ARGV.length == 2 && logger.valid_batch?(ARGV)
  logger.process_batch(ARGV)

else
  logger.output_error()

end

#-------------------------------------------------------------------
# 					Gonzalo's code
#-------------------------------------------------------------------


#if ARGV.length > 0 then
#	if ARGV[0] = "-B" then
#		file_reader ARGV[1]
#	end
#else
  #TODO
#end