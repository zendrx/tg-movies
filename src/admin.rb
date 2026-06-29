# admin.rb
module Handlers
  module Admin
    CODES_FILE = "codes.txt"

    def self.register(bot)
      admin_id = ENV["ADMIN_ID"]&.to_i

      # Overwrite all codes with a single code
      bot.command('acode') do |ctx|
        unless ctx.from&.id == admin_id
          ctx.reply("❌ Admin only.", parse_mode: "Markdown")
          next
        end

        code = ctx.command_args&.strip

        if code.nil? || code.empty?
          ctx.reply(
            "🔑 *Overwrite Access Code*\n\n" \
            "Usage: `/acode <code>`\n\n" \
            "⚠️ This replaces ALL existing codes!",
            parse_mode: "Markdown"
          )
          next
        end

        File.open(CODES_FILE, "w") do |f|
          f.puts(code)
        end

        ctx.reply(
          "✅ Code `#{code}` set.\n" \
          "⚠️ All old codes replaced.",
          parse_mode: "Markdown"
        )
      end

      # Add multiple codes (append)
      bot.command('addcode') do |ctx|
        unless ctx.from&.id == admin_id
          ctx.reply("❌ Admin only.", parse_mode: "Markdown")
          next
        end

        codes = ctx.command_args&.strip&.split

        if codes.nil? || codes.empty?
          ctx.reply(
            "🔑 *Add Access Codes*\n\n" \
            "Usage: `/addcode <code1> <code2> <code3>`\n\n" \
            "Adds multiple codes to the file.",
            parse_mode: "Markdown"
          )
          next
        end

        File.open(CODES_FILE, "a") do |f|
          codes.each { |code| f.puts(code) }
        end

        ctx.reply(
          "✅ #{codes.length} code#{codes.length > 1 ? 's' : ''} added:\n" \
          "`#{codes.join(', ')}`",
          parse_mode: "Markdown"
        )
      end
    end
  end
end
