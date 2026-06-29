# start.rb
module Handlers
  module Start
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
