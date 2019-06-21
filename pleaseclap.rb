require 'uri'
require 'net/http'
require 'json'

# This is a single file command line applet that will take your user data and clap for you 50 times on Medium. 
# It was built so my students could support each other's blogs while seeing a demonstration of the power of the Chrome Network Tab.
# I originally had this code just have them enter their variables in a cloned copy of the code but decided to have fun and make it a CLI app.

#####INTRO######
puts 'Welcome to PLEASE CLAP, an applet that allows you to clap 50 times for Medium pieces in one go.'
puts ''
puts 'To start, please first open the chrome dev tools (CMD + I) on any medium post, open up the network tab,'
puts 'clap once, and then select the new \'claps\' request that shows up in the bottom left corner of the dev tools.'
puts 'This section will have the user data you need to enter.'
puts ''
sleep(1)

#####GETTING THE USER VARIABLES#########

###These appear in the "request headers" section
# This appears as x-xsrf-token, it should be a short string of numbers and letters
puts 'In the request headers section, what is the value of \'x-xsrf-token\'?'
XSRF = gets.chomp
system("clear")
puts 'In the request headers section, what is your cookie?'
puts 'This appears as a huge friggin string labeled \'cookie\''
puts 'Don\'t worry if it has a section with the URL of the individual blog you clapped on, this cookie will still work for future blogs.'
puts '# Note: Do not upload anything with your cookie to github or send this to anyone because you will get hacked.'
COOKIE = gets.chomp
system("clear")
puts 'What is your USER ID? This appears in the \'Request Payload\' section'
# Copy string of numbers and letters from from "Request Payload" section
USERID = gets.chomp

#################################THE CODE##########################################
# With the exception of where I've commented, almost this whole set of code I got by hitting "Copy as cURL" on my Network request using Google Chrome, 
# importing into Postman, and then Exporting as ruby.
def send_a_request(url)
    # Wrote this to extract a postid from a normal url (note, if there's any additional tags this won't work. You want URLs added here to end right after the string of twelve characters after the extracted title in the name.)
    postid = url.chars.last(12).join
    # This is the posting API for medium, set as a URI using the uri gem.
    url = URI("https://medium.com/_/api/posts/#{postid}/claps")
    http = Net::HTTP.new(url.host, url.port)
    # I added the following line to allow it to be posted on a secure port
    http.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["origin"] = 'https://medium.com'
    # this is probably personal - necessary
    request["x-xsrf-token"] = XSRF
    # This is a personal cookie - necessary, but you can just use the same cookie for every blog post, which is weird, because one of the sections is the referring URL. You can totally just use the same blog post for every post.
    request["cookie"] = COOKIE
    # some of these headers are probably unnecessary (they're from postman). I felt it would be rude to test everyone individually by spamming Medium's servers with tremendous applause.
    request["accept-encoding"] = 'gzip, deflate, br'
    request["user-agent"] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36'
    request["content-type"] = 'application/json'
    request["accept"] = 'application/json'
    request["accept-language"] = 'en-US,en;q=0.9'
    request["x-obvious-cid"] = 'web'
    request["x-client-date"] = '1560874685027'
    request["authority"] = 'medium.com'
    request["Cache-Control"] = 'no-cache'
    request["Host"] = 'medium.com'
    request["content-length"] = '43'
    request["Connection"] = 'keep-alive'
    request["cache-control"] = 'no-cache'
    # Another bit of custom code, this just throws everything into JSON.
    request.body = {"userId": USERID, "clapIncrement": 50}.to_json
    response = http.request(request)
    puts "Medium's server says: #{response.message}."
    response.message === "OK" && puts("It will say OK if your auth was approved, whether or not it ended up applauding for a real piece.")
    response.message 
end

def prompt_the_user_and_send
    puts 'What is the URL of the blog you would like to applaud?'
    raw_url = gets.chomp
    usable_url = raw_url.index("?") ? raw_url.slice(0,raw_url.index("?")) : raw_url
    send_a_request(usable_url)
    ask_if_they_want_to_send_another_request
end

def ask_if_they_want_to_send_another_request
    puts 'Do you want to applaud another medium piece? Y/N'
    response = gets.chomp
    if response.downcase === "y"
        prompt_the_user_and_send
    else
        puts "Thanks for clapping."
    end
end

prompt_the_user_and_send
