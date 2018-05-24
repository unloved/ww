require 'tdlib-ruby'

class TdBot
  CHAT_ID = 430930191
  SENDER_USER_ID = 430930191
  attr_accessor :state, :client, :last_message

  def self.start
    a = self.new
    a.start
  end

  def start
    begin
      self.client = client
      set_callbacks
      sleep(3)
      while  1==1 do
        if last_message.nil? or last_message < 3.minutes.ago
          puts '<<<<<<WAKE ME UP>>>>>>>>'
          send_message(GameBotActor::ACTIONS[:update_environment])
        end
        sleep(30)
      end
    ensure
      client.close
    end
    client
  end

  def set_callbacks
    client.on('updateAuthorizationState') do |update|
      next unless update.dig('authorization_state', '@type') == 'authorizationStateReady'
      # client.broadcast_and_receive('@type' => 'getMe')
      # client.broadcast('@type': :sendMessage, chat_id: CHAT_ID, input_message_content: gamebot.get_info_message)
      # client.broadcast('@type' => 'sendMessage', 'chat_id' => 430930191, 'input_message_content'=> {'@type':'inputMessageText', 'text': '22'})
      # send_message(GameBotActor::ACTIONS[:pipboy])
      # sleep(2)
      # send_message(GameBot::ACTIONS[:stuff])
      # sleep(2)
      # send_message(GameBot::ACTIONS[:status])
    end

    client.on('updateNewMessage') do |update|
      # puts update
      next unless (update['message']['chat_id'] == CHAT_ID and update['message']['sender_user_id'] == SENDER_USER_ID)
      next if update['message']['content']['@type'] == 'messagePhoto'
      self.last_message = Time.current
      begin
        text = update['message']['content']['text']['text'].to_s
        rows = (update['message']['reply_markup'].try{|x| x['rows']} || []).flatten
        options = rows.map{|row| row['text']}
        response = gamebot.response(text, options)
        sleep(3)
        send_message(response, update) if response.present?
      rescue => e
        puts e
        puts update
      end

      puts gamebot.store
    end
  end


  def send_message text, update=nil
    if text.is_a?(String)
      client.broadcast('@type': 'sendMessage', 'chat_id': CHAT_ID, input_message_content: {'@type': 'inputMessageText', text: {'@type': 'formattedText', text: text}})
    elsif text.is_a?(Symbol)
      begin
        data = update['message']['reply_markup']['rows'].first.first['type']['data']
        client.broadcast_and_receive('@type' => 'getCallbackQueryAnswer', chat_id: CHAT_ID, message_id: update['message']['id'], payload: {'@type': 'callbackQueryPayloadData', data: data})
      rescue
        # binding.pry
      end
    end
  end

  def gamebot
    @gamebot ||= GameBot.new
  end

  def client
    @client ||= begin
      TD.configure do |config|
        config.lib_path = GameBot::LIB_PATH

        config.client.api_id = '239945'
        config.client.api_hash = 'c9a8fb04fe6391782dcde86dc6fe1fc8'
      end

      TD::Api.set_log_verbosity_level(1)

      @client = TD::Client.new
      @client
    end
  end
end
