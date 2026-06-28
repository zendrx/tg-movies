# account.rb
module Handlers
module Account
 def self.register(bot)
   bot.command('account') do |ctx|
     user = ctx.from

     if user.nil?
       ctx.reply("❌ Could not retrieve your account info.", parse_mode: "Markdown")
       next
     end

     name = [user.first_name, user.last_name].compact.join(' ')
     username = user.username ? "@#{user.username}" : "None"
     user_id = user.id
     language = user.language_code || "Unknown"
     is_premium = user.is_premium ? "✅ Yes" : "❌ No"
     is_bot = user.is_bot ? "🤖 Yes" : "👤 No"

     caption = <<~MSG
       👤 *Account Info*

       📝 *Name:* #{name}
       🔗 *Username:* #{username}
       🆔 *ID:* `#{user_id}`
       🌐 *Language:* #{language.upcase}
       ⭐ *Premium:* #{is_premium}
       🤖 *Bot:* #{is_bot}
     MSG

     ctx.photo(File.open("img/account.jpg"), caption: caption, parse_mode: "Markdown")
   end
 end
end
end
