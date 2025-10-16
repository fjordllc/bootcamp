# frozen_string_literal: true

class Mentor::BuzzesController < ApplicationController
  before_action :require_admin_or_mentor_login, only: %i[index new create edit update destroy]
  before_action :set_buzz, only: %i[edit update destroy]
  PER_PAGE = 50

  def index
    @buzzes = Buzz.order(published_at: :desc, id: :desc).page(params[:page]).per(PER_PAGE)
  end

  def new
    @buzz = Buzz.new
  end

  def edit; end

  def create
    @buzz = Buzz.new(buzz_params)

    return render :new, status: :unprocessable_entity unless validate_url_presence

    doc = Buzz.doc_from_url(buzz_params[:url])

    unless doc.present?
      @buzz.errors.add(:url, 'から情報を取得できませんでした。URLが正しいか、またはサイトがアクセス可能か確認してください')
      return render :new, status: :unprocessable_entity
    end

    date = Buzz.date_from_doc(doc)

    @buzz.title = Buzz.title_from_doc(doc) if @buzz.title.blank?

    if @buzz.published_at.blank?
      if date.present?
        @buzz.published_at = date
      else
        @buzz.errors.add(:published_at, 'を入力してください')
        return render :new, status: :unprocessable_entity
      end
    end

    if @buzz.save
      redirect_to mentor_buzzes_path, notice: '記事を登録しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @buzz.update(buzz_params)
      redirect_to mentor_buzzes_path, notice: '記事を更新しました', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @buzz.destroy
    redirect_to mentor_buzzes_path, status: :see_other
  end

  private

  def validate_url_presence
    if @buzz.url.present?
      true
    else
      @buzz.errors.add(:url, 'を入力してください')
      false
    end
  end

  def set_buzz
    @buzz = Buzz.find(params[:id])
  end

  def buzz_params
    keys = %i[title memo published_at]
    keys << :url if action_name == 'create'
    params.require(:buzz).permit(*keys)
  end
end
