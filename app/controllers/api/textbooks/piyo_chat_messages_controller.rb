# frozen_string_literal: true

class API::Textbooks::PiyoChatMessagesController < API::BaseController
  include TextbookFeatureGuard
  before_action :require_textbook_enabled

  def index
    messages = current_user.piyo_chat_messages
                           .where(textbook_section_id: params[:section_id])
                           .order(created_at: :asc)

    render json: messages.map { |m| message_json(m) }
  end

  def create
    section = Textbook::Section.find(params[:section_id])

    user_message = current_user.piyo_chat_messages.create!(
      textbook_section_id: section.id,
      role: 'user',
      content: params[:content]
    )

    response_text = PiyoChatService.respond(
      user: current_user,
      section: section,
      message: params[:content]
    )

    assistant_message = current_user.piyo_chat_messages.create!(
      textbook_section_id: section.id,
      role: 'assistant',
      content: response_text
    )

    render json: {
      user_message: message_json(user_message),
      assistant_message: message_json(assistant_message)
    }, status: :created
  end

  private

  def message_json(message)
    {
      id: message.id,
      role: message.role,
      content: message.content,
      created_at: message.created_at
    }
  end
end
