# frozen_string_literal: true

class Mentor::BuzzesController < ApplicationController
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

    doc = Buzz.doc_from_url(buzz_params[:url])
    date = Buzz.date_from_doc(doc)

    @buzz.title = Buzz.title_from_doc(doc) if buzz_params[:title].empty?

    if buzz_params[:published_at].empty?
      if date.nil?
        flash.now[:alert] = '日付を入力してください'
      else
        @buzz.published_at = date
      end
    end

    if @buzz.save
      redirect_to mentor_buzzes_path, notice: 'Buzz was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @buzz.update(buzz_params)
      redirect_to mentor_buzzes_path, status: :see_other
    else
      render 'edit'
    end
  end

  def destroy
    @buzz.destroy
    redirect_to mentor_buzzes_path, status: :see_other
  end

  private

  def set_buzz
    @buzz = Buzz.find(params[:id])
  end

  def buzz_params
    keys = %i[title memo published_at]
    keys << :url if action_name == 'create'
    params.require(:buzz).permit(*keys)
  end
end
