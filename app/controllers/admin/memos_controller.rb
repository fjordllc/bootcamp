# frozen_string_literal: true

class Admin::MemosController < AdminController
  before_action :set_memo, only: [:edit, :update, :destroy]

  def index
    @memos = Memo.all
  end

  def new
    @memo = Memo.new
  end

  def edit
  end

  def create
    @memo = Memo.new(memo_params)

    if @memo.save
      redirect_to admin_memos_path, notice: "メモを作成しました。"
    else
      render :new
    end
  end

  def update
    if @memo.update(memo_params)
      redirect_to admin_memos_path, notice: "メモを更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @memo.destroy
    redirect_to admin_memos_path, notice: "メモを削除しました。"
  end

  private
    def set_memo
      @memo = Memo.find(params[:id])
    end

    def memo_params
      params.require(:memo).permit(:date, :body)
    end
end
