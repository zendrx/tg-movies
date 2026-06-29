# account.rb
module Handlers
  module Account
    def self.register(bot)
      bot.hears('👤 Account') do |ctx|
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

        # Referral stats
        referred_by = ctx.session[:referred_by]
        referral_count = ctx.session[:referral_count] || 0

        referral_info = if referred_by
                          "🔗 *Referred By:* `#{referred_by}`\n"
                        else
                          ""
                        end

        caption = <<~MSG
          👤 *Account Profile*

          📝 *Name:* #{name}
          🔗 *Username:* #{username}
          🆔 *ID:* `#{user_id}`
          🌐 *Language:* #{language.upcase}
          ⭐ *Status:* #{is_premium}

          📊 *Referral Stats*
          #{referral_info}👥 *Referrals:* #{referral_count}
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
