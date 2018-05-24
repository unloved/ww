require 'tdlib-ruby'

class LoginBot
  attr_accessor :state, :client

  def self.start
    a = self.new
    a.start
  end

  def start
    begin
      state = nil

      client.on('updateAuthorizationState') do |update|
        next unless update.dig('authorization_state', '@type') == 'authorizationStateWaitPhoneNumber'
        state = :wait_phone
      end

      client.on('updateAuthorizationState') do |update|
        next unless update.dig('authorization_state', '@type') == 'authorizationStateWaitCode'
        state = :wait_code
      end

      client.on('updateAuthorizationState') do |update|
        next unless update.dig('authorization_state', '@type') == 'authorizationStateReady'
        state = :ready
      end

      loop do
        case state
        when :wait_phone
          p 'Please, enter your phone number:'
          phone = STDIN.gets.strip
          params = {
            '@type' => 'setAuthenticationPhoneNumber',
            'phone_number' => phone
          }
          client.broadcast_and_receive(params)
        when :wait_code
          p 'Please, enter code from SMS:'
          code = STDIN.gets.strip
          params = {
            '@type' => 'checkAuthenticationCode',
            'code' => code
          }
          client.broadcast_and_receive(params)
        when :ready
          @me = client.broadcast_and_receive('@type' => 'getMe')
          break
        end
      end

    ensure
      client.close
    end
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
