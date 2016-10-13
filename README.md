# botstack

![botstack-logo](https://cloud.githubusercontent.com/assets/1736570/18914167/33193656-858c-11e6-9151-b383bd1c821c.png)

This is a base project for creating FB Chatbots. It has a state machine and User Management and allows you to add functionality with modules.

## Quickstart

Put all your logic into lib/bot. We've already prepared everything for you to kickstart your project.

**@fb_params** holds 
**@request_type** holds the type of the request. Could be one of the following:
* DELIVERY (maybe will be removed in the future, to disruptive)
* OPTIN
* CALLBACK
* TEXT
* IMAGE -> @fb_params has the url to the image
* LOCATION-> @fb_params has the long / lat 
* AUDIO -> @fb_params has the url to the mp3 file
* ATTACHMENT_UNKNOWN -> @fb_params has the url to the ATTACHMENT_UNKNOWN (mostly http links fucked up with fb outbound link system)
**@current_user** hold infos of your current user (last seen, state machine, user id ...)

![botstack grafik-x](https://cloud.githubusercontent.com/assets/1736570/19266341/6955d374-8fa9-11e6-8454-15f0b76730f6.png)


## Reply Module

This function will reply a message back to the user who sent one. you can use Spintax and Emojs.
```ruby
 def reply_message(msg, options={})

 def example()
  reply_message "make {:pizza:|:sushi:|:lemon:} great again!"
 end
```

This function will send an image back to the user who sent a message to your bot.
```ruby
 def reply_image(img_url)
```

This function will render HTML and send an image back to the user who sent a message to your bot.
```ruby
 def reply_html(html)
```

This function will render a bubble and send it to the user.
```ruby
 def reply_bubble
```
This function will return a string containing the message a user sent to your bot.
```ruby
 def get_message
```

## Emoji Module
Most of the time you will not need the Emoji Module because it is already integrated into the reply module.


This function will return the UTF-8 representation of the given [Emoji Name](http://www.webpagefx.com/tools/emoji-cheat-sheet/)
```ruby
 def get_emoji(name)
```
This function will send a reply message with the UTF-8 representation of the given [Emoji Name](http://www.webpagefx.com/tools/emoji-cheat-sheet/)
```ruby
 def reply_emoji(name)
```

This function will be always used with the reply_message function of the repy module. It will search for emoji names surrounded with : and replaces them with the UTF-8 representation of the given [Emoji Name]
```ruby
 def compute_emojis(content)
```

This function is the opposite of the function above.
```ruby
 def parse_emojis(content)
```


## Web Search Module

With the web search module you can transport websites to messengers. Just add two methods to your bot logic. One for handling search requests and one for handling user input on the search results.

```ruby
search_request_on_website(
	url: "http://www.example.com/",
	form_name: 'search',
	result_css_selector: '.result > a',
	image_css_selector: 'img',
	button_text: 'more infos'
)

handle_search_result(
	url: "http://www.example.com",
	result_css_selector: ".result"
)
```

## State Machine Module
This Module will help you with guiding users through different states of your bot.

Example usage of the State Machine Module:
```ruby
class BotLogic < BaseBotLogic

	def self.bot_logic
		state_action 0, :greeting
		state_action 1, :turorial
		state_action 2, :bye
	end

	def self.greeting
		reply_message "greeting"
		state_go
	end 

	def self.turorial
		reply_message "turorial"
		state_go
	end 

	def self.bye
		reply_message "bye"
		state_reset
	end 

end
```

## Installation
clone the repo
copy config/settings.yml to settings.local.yml and enter your api keys
use ngrok or another vpn to tunnel your connection
run the following commands
```console
bundle install
rails s
```
set the webhook to https://tunnel_url/bot and use your token (default: github)


## Contributing
  - Fork it!
  - Create your feature branch: `git checkout -b my-new-feature`
  - Commit your changes: `git commit -am 'Useful information about your new features'`
  - Push to the branch: `git push origin my-new-feature`
  - Submit a pull request on the `Development` branch :D
  
## gems used
* [https://github.com/hyperoslo/facebook-messenger](https://github.com/hyperoslo/facebook-messenger)
 
