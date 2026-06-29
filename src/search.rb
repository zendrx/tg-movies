# search.rb
require 'httparty'

module Handlers
  module Search
    API_BASE = "https://api.dailymotion.com"

    def self.register(bot)
      bot.command('search') do |ctx|
        query = ctx.command_args&.strip

        if query.nil? || query.empty?
          ctx.reply(
            "🎬 *Search for a movie or series*\n\n" \
            "Usage: `/search <movie name>`\n" \
            "Example: `/search Spider Man`",
            parse_mode: "Markdown"
          )
          next
        end

        ctx.typing

        results = search_videos(query)

        if results.empty?
          ctx.reply(
            "❌ *No results found for:* `#{query}`\n\n" \
            "💡 *Tips:*\n" \
            "• Check your spelling\n" \
            "• Try a shorter name\n" \
            "• Use English titles",
            parse_mode: "Markdown"
          )
          next
        end

        lines = results.map.with_index(1) do |video, i|
          rating_bar = rating_visual(video[:rating])
          views = format_views(video[:views])
          duration = format_duration(video[:duration])

          <<~RESULT
            #{i}. #{video[:title]}
            ⭐ #{video[:rating] || 'N/A'} #{rating_bar}
            👁 #{views}  ⏱ #{duration}
          RESULT
        end

        message = <<~MSG
          🔍 *Search Results for:* `#{query}`

          #{lines.join("\n")}

          📌 *Found #{results.length} result#{results.length > 1 ? 's' : ''}*
          💡 Use `/watch <name> <code>` to stream
        MSG

        ctx.reply(message, parse_mode: "Markdown")
      end
    end

    private

    def self.search_videos(query)
      response = HTTParty.get(
        "#{API_BASE}/videos",
        query: {
          search: query,
          limit: 5,
          fields: "id,title,duration,views_total,rating"
        }
      )

      return [] unless response.success?

      data = response.parsed_response
      return [] unless data["list"]

      data["list"].map do |v|
        {
          id: v["id"],
          title: v["title"],
          duration: v["duration"],
          views: v["views_total"],
          rating: v["rating"]
        }
      end
    rescue => e
      []
    end

    def self.rating_visual(rating)
      return "⚪⚪⚪⚪⚪" unless rating
      stars = (rating / 2.0).round
      "⭐" * stars + "⚫" * (5 - stars)
    end

    def self.format_views(num)
      return "N/A" unless num
      if num >= 1_000_000
        "#{(num / 1_000_000.0).round(1)}M"
      elsif num >= 1_000
        "#{(num / 1_000.0).round(1)}K"
      else
        num.to_s
      end
    end

    def self.format_duration(seconds)
      return "N/A" unless seconds
      min, sec = seconds.divmod(60)
      hr, min = min.divmod(60)
      hr > 0 ? "#{hr}h #{min}m" : "#{min}m"
    end
  end
end
