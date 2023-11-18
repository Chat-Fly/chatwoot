class Integrations::ChatflyBaseService
  ALLOWED_EVENT_NAMES = %w[rephrase summarize reply_suggestion fix_spelling_grammar shorten expand make_friendly make_formal simplify].freeze
  CACHEABLE_EVENTS = %w[].freeze
  API_URL = 'https://backend.chatfly.co/api/chat/get-streaming-response-with-chat-history'.freeze

  pattr_initialize [:hook!, :event!]

  def perform
    return nil unless valid_event_name?
    return value_from_cache if value_from_cache.present?

    response = send("#{event_name}_message")
    save_to_cache(response) if response.present?

    response
  end

  private

  def save_to_cache(response)
    return nil unless event_is_cacheable?

    Redis::Alfred.setex(cache_key, response)
  end

  def event_name
    event['name']
  end

  def valid_event_name?
    self.class::ALLOWED_EVENT_NAMES.include?(event_name)
  end

  def cache_key
    return nil unless event_is_cacheable?

    conversation = find_conversation
    return nil unless conversation

    # since the value from cache depends on the conversation last_activity_at, it will always be fresh
    format(::Redis::Alfred::OPENAI_CONVERSATION_KEY, event_name: event_name, conversation_id: conversation.id,
                                                     updated_at: conversation.last_activity_at.to_i)
  end

  def find_conversation
    hook.account.conversations.find_by(display_id: event['data']['conversation_display_id'])
  end

  def value_from_cache
    return nil unless event_is_cacheable?

    return nil if cache_key.blank?

    Redis::Alfred.get(cache_key)
  end

  def event_is_cacheable?
    # self.class::CACHEABLE_EVENTS is way to access CACHEABLE_EVENTS defined in the class hierarchy of the current object.
    # This ensures that if CACHEABLE_EVENTS is updated elsewhere in it's ancestors, we access the latest value.
    self.class::CACHEABLE_EVENTS.include?(event_name)
  end

  def make_api_call(body)
    headers = {
      'Content-Type' => 'application/json',
      'accept' => 'application/json'
    }

    Rails.logger.info("ChatFly API request: #{body}")
    response = HTTParty.post(API_URL, headers: headers, body: body)
    Rails.logger.info("ChatFly API response: #{response.body}")

    response.present? ? response.body : nil
  end
end
