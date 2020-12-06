# frozen_string_literal: true

class API::MemosController < API::BaseController
  before_action :require_admin_login_for_api
  before_action :set_memo, only: %i[update destroy]

  def create
    memo = Memo.new(memo_params)
    if memo.save
      render status: :created, json: { id: memo.id, body: memo.body }
    else
      render status: :unprocessable_entity, json: { message: memo.errors.full_messages }
    end
  end

  def update
    if @memo.update(memo_params)
      render status: :ok, json: { id: @memo.id, body: @memo.body }
    else
      render status: :unprocessable_entity, json: { message: memo.errors.full_messages }
    end
  end

  def destroy
    @memo.destroy
    render status: :ok, json: { id: @memo.id }
  end

  private

  def set_memo
    @memo = Memo.find(params[:id])
  end

  def memo_params
    params.require(:memo).permit(:date, :body)
  end
end
