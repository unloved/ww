require 'tdlib-ruby'

class TdBot
  CHAT_ID = 430930191
  SENDER_USER_ID = 430930191
  attr_accessor :state, :client

  def self.start
    a = self.new
    a.start
  end

  def start
    self.client = client
    set_callbacks
    sleep(3)
    response = gamebot.response('', [])
    send_message(response) if response.present?
    # while  1==1 do
    #   action = gamebot.action
    #   puts action
    #   send_message action if action
    #   sleep(5)
    # end
    # send_message(response) if response.present?
    # response = gamebot.response(text, options)
    # puts response
    # sleep(1)
    # send_message(response) if response.present?
    # client
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
      next unless (update['message']['chat_id'] == CHAT_ID and update['message']['sender_user_id'] == SENDER_USER_ID)
      next if update['message']['content']['@type'] == 'messagePhoto'
      begin
        text = update['message']['content']['text']['text'].to_s
        rows = (update['message']['reply_markup'].try{|x| x['rows']} || []).flatten
        options = rows.map{|row| row['text']}
        response = gamebot.response(text, options)
        # sleep(2)
        send_message(response) if response.present?
      rescue => e
        puts e
        puts update
      end

      puts gamebot.store
    end
  end


  def send_message text
    client.broadcast('@type': 'sendMessage', 'chat_id': CHAT_ID, input_message_content: {'@type': 'inputMessageText', text: {'@type': 'formattedText', text: text}})
  end

  def gamebot
    @gamebot ||= GameBot.new
  end

  def client
    @client ||= begin
      TD.configure do |config|
        config.lib_path = '/Users/unloved/www/td/build'

        config.client.api_id = '239945'
        config.client.api_hash = 'c9a8fb04fe6391782dcde86dc6fe1fc8'
      end

      TD::Api.set_log_verbosity_level(1)

      @client = TD::Client.new
      @client
    end
  end
end
