require 'telegram/bot'
class WebhookController < ApplicationController
  def receive
    if !params[:message].nil?
      message = params[:message]
    else
      message = params[:channel_post]
    end

    return if message.nil?
    
    if message[:type] != "channel"
      id = message[:chat][:id]
      username = message[:chat][:username]
      type = message[:chat][:type]

      unless message[:text].nil? 
        text = message[:text]
      else
        text = message[:caption]
      end  
    else
      # canale
      id = message[:sender_chat][:id]
      username = message[:title]
      text = message[:text]
      type = "channel"
    end


    Telegram::Bot::Client.run(ENV["TOKEN"]) do |bot|
      if text.start_with?("/start")
        unless (chat = Chat.find_by(chat_id: id))
          Chat.create(chat_id: id, username: username)
        else
          chat.update(username: username)
        end

        bot.api.send_message(chat_id: id, text: "Il bot è stato attivato. Da ora riceverai le notizie da Wikinotizie in Italiano (https://it.wikinotizie.org)")
      elsif text.start_with?("/stop")
        if (chat = Chat.find_by(chat_id: id))
          chat.destroy
          bot.api.send_message(chat_id: id, text: "Il bot è stato disattivato. Da ora non riceverai più le notizie da Wikinotizie in Italiano (https://it.wikinotizie.org). Usa /start per attivarlo di nuovo.")
        else
          bot.api.send_message(chat_id: id, text: "Il bot non era attivo.")
        end
      elsif text.include?("@#{ENV["BOT_USERNAME"]}") || type == "private"
        bot.api.send_message(chat_id: id, text: "Comando non riconosciuto")
      end
    end

    respond_to do |format|
      format.json { render :json => {:result => :done }, :status => 200 }
    end
  end
end