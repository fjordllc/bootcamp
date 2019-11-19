# frozen_string_literal: true

class API::MemosController < API::BaseController
  before_action :set_memo, only: [:update, :destroy]

  def create
    if current_user.admin?
      memo = Memo.new(memo_params)
      if memo.save
        render json: { status: 201,  id: memo.id, body: memo.body }, status: :created
      else
        head :bad_request
      end
    end
  end

  def update
    if current_user.admin?
      if @memo.update(memo_params)
        render json: { status: 200,  id: @memo.id, body: @memo.body }, status: :ok
      else
        head :bad_request
      end
    end
  end

  def destroy
    if current_user.admin?
      @memo.destroy
      render json: { status: 200, id: @memo.id }, status: :ok
    end
  end

  private
    def set_memo
      @memo = Memo.find(params[:id])
    end

    def memo_params
      params.require(:memo).permit(:date, :body)
    end
end
