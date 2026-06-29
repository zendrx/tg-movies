# start.rb
module Handlers
  module Start
    GROUP_ID = ENV["GROUP_ID"]

    def self.register(bot)
      bot.command('start') do |ctx|
        welcome_text = <<~TEXT
          🎌 *Welcome to AniStream!*

          Watch anime & donghua *ad-free* — no interruptions, pure vibes.

          👇 Join our group for daily codes & updates:
        TEXT

        inline = Telegem.inline do
          row url("⛩️ Join Group", "https://t.me/tgtomovies2")
        end

        keyboard = Telegem.keyboard do
          row "🎬 Anime", "📺 Donghua"
          row "👤 Account", "🔗 Refer"
          row "❓ Help"
        end
        keyboard.resize

        # Check if user was referred
        referrer_id = ctx.command_args&.strip

        if referrer_id && referrer_id.match?(/^\d+$/)
          referrer_id = referrer_id.to_i

          # Don't self-refer
          if referrer_id != ctx.from.id
            ctx.session[:referred_by] = referrer_id

            # Send notification to group with usernames
            if GROUP_ID
              begin
                new_user = ctx.from
                new_user_mention = new_user.username ? "@#{new_user.username}" : "[#{new_user.first_name}](tg://user?id=#{new_user.id})"

                bot.api.call('sendMessage', {
                  chat_id: GROUP_ID,
                  text: "🎉 *New Referral!*\n\n" \
                        "👤 *New User:* #{new_user_mention}\n" \
                        "🆔 *New User ID:* `#{new_user.id}`\n\n" \
                        "🔗 *Referred By ID:* `#{referrer_id}`\n\n" \
                        "💰 Admin can reward referrer!",
                  parse_mode: "Markdown",
                  disable_web_page_preview: true
                })
              rescue => e
                ctx.logger&.error("Failed to send referral notification: #{e.message}")
              end
            end
          end
        end

        ctx.photo(
          "https://tomoviestv.netlify.app/img/welcome.jpg",
          caption: welcome_text,
          parse_mode: "Markdown",
          reply_markup: inline
        )

        ctx.reply("Choose what to watch:", reply_markup: keyboard)
      end
    end
  end
end
