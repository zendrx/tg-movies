# refer.rb
module Handlers
  module Refer
    GROUP_ID = ENV["GROUP_ID"]

    def self.register(bot)
      bot.hears('🔗 Refer') do |ctx|
        user = ctx.from
        user_id = user.id
        username = user.username ? "@#{user.username}" : user.first_name

        # Generate referral link
        refer_link = "https://t.me/tgtomoviesbot?start=#{user_id}"

        # Send to group for admin tracking
        if GROUP_ID
          begin
            bot.api.call('sendMessage', {
              chat_id: GROUP_ID,
              text: "📋 *Referral Link Generated*\n\n" \
                    "👤 *User:* #{username}\n" \
                    "🆔 *User ID:* `#{user_id}`\n" \
                    "🔗 *Refer Link:* `#{refer_link}`",
              parse_mode: "Markdown",
              disable_web_page_preview: true
            })
          rescue => e
            ctx.logger&.error("Failed to send refer notification: #{e.message}")
          end
        end

        # Reply to user
        message = <<~MSG
          🔗 *Your Referral Link*

          Share this link with friends:

          `#{refer_link}`

          🎁 Earn rewards when they join!
        MSG

        ctx.reply(message, parse_mode: "Markdown")
      end
    end
  end
end
