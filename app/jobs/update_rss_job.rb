require 'telegram/bot'
include ActionView::Helpers::SanitizeHelper
class UpdateRssJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Telegram::Bot::Client.run(ENV["TOKEN"]) do |bot|
      page = HTTParty.get("https://it.wikipedia.org/w/api.php", query: { action: :query, prop: :revisions, rvslots: "*", rvprop: :content, titles:"Template:Bar3/titoli/0", format: :json})
      bar_content = page["query"]["pages"].first[1]["revisions"].first["slots"]["main"]["*"]

      break if bar_content.strip == "<dl><dd>''Nessuna discussione.''</dd></dl>"

      bar_content = bar_content.gsub("<dl><dd>", "").gsub("</dd></dl>","").gsub("<br/>","")

      discussioni = bar_content.split(" &middot; ")

      discussioni.each do |article|
        if article.starts_with?("{{")
          title = article.match(/{{Bar3\/esterna\|([^\}}]+)}}/)[1].split("|")[1]
          existence_title = article.match(/{{Bar3\/esterna\|([^\}}]+)}}/)[1].split("|")[0]
          url = "https://it.wikipedia.org/wiki/#{existence_title}"
          external = true
        else
          title = article.match(/\[\[([^\]]+)\]\]/)[1].split("|")[1]
          existence_title = article.match(/\[\[([^\]]+)\]\]/)[1].split("|")[0]
          url = "https://it.wikipedia.org/wiki/#{existence_title}"
          external = false
        end

        escaped_url = Addressable::URI.encode(url).gsub("?", "%3F").gsub("=", "%3D").gsub("&", "%26")

        existence = HTTParty.get("https://it.wikipedia.org/w/api.php", query: { action: :query, prop: :info, titles: existence_title, format: :json})

        next unless existence["query"]["pages"]["-1"].nil?

        next if title.include?("SCRIVI QUI SOLO IL TITOLO")

        next if Article.exists?(title: title)

        Article.create(title: title)

        Chat.all.each do |chat|
          begin
            bot.api.send_message(chat_id: chat.chat_id, text: "<b>Nuova discussione al bar#{external ? " (esterna)" : ""}</b>: <a href='#{escaped_url}'>#{title}</a>", parse_mode: :HTML)
          rescue => e
            if e.error_code == 403
              chat.destroy
            else
              bot.api.send_message(chat_id: ENV["FALLBACK"].to_i, text: "Errore #{e} nell'invio del messaggio al bar <a href='#{escaped_url}'>#{title}</a> a #{chat.chat_id} - #{chat.username}", parse_mode: :HTML)
            end
          end
        end
      end
    end
  end
end
