require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing MicroBlogger"
		@client = JumpstartAuth.twitter
	end
	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""
		while command != "q"
			printf "enter command: "
			input= gets.chomp
			parts= input.split(' ')
			command = parts[0]
			case command
				when 'q' then puts "Goodbye!"
				when 't' then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(' '))
				when 'elt' then everyones_last_tweet
				when 's' then shorten(parts[1..-1].join(' '))
				when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end

	def tweet(message)
		@client.update(message)
		puts "".ljust(140, "abcd")
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message:"
	    puts message
	    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
	    if screen_names.include?(target)
	      msg = "d #{target} #{message}"
	      tweet(msg)
	    else
	      puts 'ERROR: can only send direct message to followers.'
		end
	end

	def followers_list
		screen_names=[]
		@client.followers.each {|follower| screen_names << @client.user(follower).screen_name }
		screen_names
	end

	def spam_my_followers(message)
		list= followers_list
		list.each {|f| dm(f,message)}
	end

	def everyones_last_tweet
		friends= @client.friends.sort_by {|friend| @client.user(friend).screen_name.downcase}
		friends.each do |friend|
			timestamp= @client.user(friend).created_at
			puts "#{client.user(friend).screen_name}, #{timestamp.strftime('%A, %b %d')}, says:"
			puts @client.user(friend).status.text
			puts " "
		end
	end
	def shorten(original_url)
		puts "shortening this URL: #{original_url}"
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
  		bitly.shorten(original_url).short_url
  	end
end

blogger=MicroBlogger.new
blogger.run