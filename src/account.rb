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
        is_premium = user.is_premium ? "💎 Premium" : "🆓 Free"
        is_bot = user.is_bot ? "🤖 Bot" : "👤 Human"

        visit_count = ctx.session[:visit_count] ||= 0
        ctx.session[:visit_count] += 1

        badge = case visit_count
                when 0 then "🆕 Newbie"
                when 1..5 then "🎬 Watcher"
                when 6..20 then "🍿 Movie Buff"
                else "🏆 Cinema Legend"
                end

        caption = <<~MSG
          👤 *Account Profile*

          📝 *Name:* #{name}
          🔗 *Username:* #{username}
          🆔 *ID:* `#{user_id}`
          🌐 *Language:* #{language.upcase}
          ⭐ *Status:* #{is_premium}
          🤖 *Type:* #{is_bot}

          📊 *Stats*
          🎯 *Visits:* #{visit_count + 1}
          🏅 *Rank:* #{badge}
        MSG

        ctx.photo(
          "https://tomoviestv.netlify.app/img/account.jpg",
          caption: caption,
          parse_mode: "Markdown"
        )
      end
    end
  end
end
