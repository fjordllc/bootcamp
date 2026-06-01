# frozen_string_literal: true

require 'timeout'

class API::Pjord::ChatMessagesController < API::BaseController
  MESSAGE_MAX_LENGTH = 2_000
  HOURLY_MESSAGE_LIMIT = 20
  RESPONSE_TIMEOUT = 30.seconds

  before_action :require_student_or_trainee
  before_action -> { doorkeeper_authorize! :read }, only: :index, if: -> { doorkeeper_token.present? }
  before_action -> { doorkeeper_authorize! :write }, only: :create, if: -> { doorkeeper_token.present? }

  def index
    return render json: { messages: [] } if current_user.pjord_chat_session.blank?

    render json: {
      messages: current_user.pjord_chat_session.messages.order(:created_at).last(50).map { |message| message_json(message) }
    }
  end

  def create
    body = params[:message].to_s.strip
    return render_bad_request('相談内容を入力してください。') if body.blank?
    return render_bad_request("相談内容は#{MESSAGE_MAX_LENGTH}文字以内で入力してください。") if body.length > MESSAGE_MAX_LENGTH
    return render_rate_limited if rate_limited?

    create_chat_response(body)
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  rescue StandardError => e
    render_chat_failure(e)
  end

  private

  def create_chat_response(body)
    @user_message = writable_chat_session.messages.create!(role: 'user', body:)
    assistant_body = fetch_assistant_body(body)
    assistant_message = writable_chat_session.messages.create!(role: 'assistant', body: assistant_body.presence || fallback_message)

    render json: {
      user_message: message_json(@user_message),
      assistant_message: message_json(assistant_message)
    }, status: :created
  end

  def fetch_assistant_body(body)
    Timeout.timeout(RESPONSE_TIMEOUT) do
      Pjord::ChatAgent.reply(
        user: current_user,
        message: body,
        recent_messages: writable_chat_session.messages.order(:created_at).where.not(id: @user_message.id).last(10)
      )
    end
  end

  def render_chat_failure(error)
    Rails.logger.error("[PjordChat] Failed to create chat response: user_id=#{current_user.id} #{error.class}: #{error.message}")
    assistant_message = @user_message&.session&.messages&.create(role: 'assistant', body: fallback_message)

    render json: {
      message: fallback_message,
      user_message: @user_message && message_json(@user_message),
      assistant_message: assistant_message&.persisted? ? message_json(assistant_message) : nil
    }, status: :service_unavailable
  end

  def writable_chat_session
    @chat_session ||= current_user.pjord_chat_session || current_user.create_pjord_chat_session!
  rescue ActiveRecord::RecordNotUnique
    @chat_session = current_user.reload.pjord_chat_session
  end

  def require_student_or_trainee
    render json: { error: 'forbidden' }, status: :forbidden unless current_user.student_or_trainee?
  end

  def rate_limited?
    return false if current_user.pjord_chat_session.blank?

    current_user.pjord_chat_session.messages.where(role: 'user', created_at: 1.hour.ago..).count >= HOURLY_MESSAGE_LIMIT
  end

  def render_rate_limited
    render json: { message: '短時間の相談回数が上限に達しました。時間をおいてもう一度試してください。' }, status: :too_many_requests
  end

  def message_json(message)
    {
      id: message.id,
      role: message.role,
      body: message.body,
      created_at: message.created_at
    }
  end

  def fallback_message
    'すみません、今はうまく回答できませんでした。時間をおいてもう一度試すか、メンターに相談してください。'
  end
end
