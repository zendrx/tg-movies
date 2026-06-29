# help.rb
module Handlers
  module Help
    def self.register(bot)
      bot.hears('❓ Help') do |ctx|
        text = <<~MSG
          🎌 *AniStream Bot Help*

          *Getting Started*
          • Tap 🎬 *Anime* to search Japanese anime
          • Tap 📺 *Donghua* to search Chinese anime
          • Get a code from the group to unlock watching

          *Commands*
          `/start` — Welcome & main menu
          `/search <name>` — Quick search anything

          *Keyboard Buttons*
          🎬 *Anime* — Search anime by name + code
          📺 *Donghua* — Search donghua by name + code
          👤 *Account* — Your profile & referral stats
          🔗 *Refer* — Get your referral link
          ❓ *Help* — Show this message

          *Watching*
          1. Get a code from @tgtomovies2
          2. Search your title
          3. Tap Watch Now
          4. Switch servers if needed

          *Referrals*
          Share your link. Earn rewards. Admin tracks all in group.

          *Need Help?*
          Join @tgtomovies2 for support.
        MSG

        ctx.reply(text, parse_mode: "Markdown")
      end
    end
  end
end
