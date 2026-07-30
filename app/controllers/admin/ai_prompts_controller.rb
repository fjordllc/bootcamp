# frozen_string_literal: true

class Admin::AiPromptsController < AdminController
  before_action :set_ai_prompt, only: %i[edit update]

  def index
    @definitions = AiPrompt.definitions
  end

  def edit; end

  def update
    if @ai_prompt.update(ai_prompt_params)
      redirect_to admin_ai_prompts_path, notice: 'AIプロンプトを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_ai_prompt
    key = params[:key]
    raise ActiveRecord::RecordNotFound unless AiPrompt.definitions.key?(key)

    @ai_prompt = AiPrompt.find_or_initialize_by(key:)
    @ai_prompt.body = AiPrompt.default_body_for(key) if @ai_prompt.new_record?
  end

  def ai_prompt_params
    params.require(:ai_prompt).permit(:body)
  end
end
