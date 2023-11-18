class Accounts::ChatflyBaseService
  attr_accessor :user, :account, :info

  HTTP_URL = ENV.fetch('HTTP_URL', 'https://backend.dev.chatfly.co')
  SIGNUP_URL = '/api/user'.freeze
  ACTIVE_URL = '/api/user/activate-account-user?email='.freeze
  CREATE_BOT = '/api/bot'.freeze

  def initialize(user, _account)
    @user = user
    @account = _account
  end

  def create_account_chatfly
    body = {
      email: user.email,
      password: user.password,
      full_name: user.name,
      role: 'user'
    }.to_json
    response = make_api_call(body, SIGNUP_URL)
    return if response.blank? || response['message_code'].present?

    create_information_chatfly_account(response)
  end

  private

  def create_information_chatfly_account(response)
    obj = {
      uuid: response['id'],
      email: response['email'],
      is_active: response['is_active']
    }
    @info = user.chatfly_accounts.create(obj)
    active_account_chatfly
  end

  def active_account_chatfly
    body = {}
    response = make_api_call(body, ACTIVE_URL + info.email)
    return if response.blank?

    info.update!(token: response['data']['access_token'], token_type: response['data']['token_type'], is_active: true)
    create_bot_chatfly
  end

  def create_bot_chatfly
    body = {
      user_id: info.uuid,
      bot_name: "#{info.user.name}Bot",
      case_study: 'Customer Support'
    }.to_json

    response = make_api_call(body, CREATE_BOT)
    info.update!(bot_id: response['id'])
    create_integration_chatfly
  end

  def create_integration_chatfly
    obj = {
      app_id: 'chatfly',
      settings: {
        api_key: info.bot_id
      }
    }
    account.hooks.create!(obj)
  end

  def make_api_call(body, _url)
    headers = {
      'Content-Type' => 'application/json',
      'accept' => 'application/json'
    }
    Rails.logger.info("ChatFly API request: #{body}")
    headers['Authorization'] = "Bearer #{info.token}" if _url == CREATE_BOT
    response = HTTParty.post(HTTP_URL + _url, headers: headers, body: body)
    Rails.logger.info("ChatFly API response: #{response.body}")

    response.present? ? JSON.parse(response.body) : nil
  end
end
