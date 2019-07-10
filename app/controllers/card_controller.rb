# frozen_string_literal: true

class CardController < ApplicationController
  before_action :require_login
  before_action :require_paid_login, only: %i(show edit update)
  before_action :already_registered_card, only: %i(new)

  def show
    @card = current_user.card
  end

  def new
  end

  def edit
  end

  def create
    begin
      customer = Card.create(current_user, params[:stripeToken])
      curernt_user.update(customer_id: customer["id"])
      Subscription.create(current_user.customer_id)

      flash[:notice] = "カードを登録しました。"
      logger.info "[Payment] カードを登録しました。"
    rescue Stripe::CardError => e
      current_user.update!(customer_id: nil)
      flash[:alert] = "カード情報に不備があります。：#{e.message}"
      logger.warn "[Payment] カード情報に不備があります。：#{e.message}"
    rescue => e
      current_user.update!(customer_id: nil)
      flash[:alert] = "カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
      logger.warn "[Payment] カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
    end

    if flash[:alert]
      redirect_to new_card_url
    else
      redirect_to card_url
    end
  end

  def update
    begin
      Card.update(current_user.customer_id, params[:stripeToken])

      flash[:notice] = "カードを編集しました。"
      logger.info "[Payment] カードを登録しました。"
    rescue Stripe::CardError => e
      current_user.update!(customer_id: nil)
      flash[:alert] = "カード情報に不備があります。：#{e.message}"
      logger.warn "[Payment] カード情報に不備があります。：#{e.message}"
    rescue => e
      current_user.update!(customer_id: nil)
      flash[:alert] = "カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
      logger.warn "[Payment] カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
    end

    if flash[:alert]
      redirect_to edit_card_url
    else
      redirect_to card_url
    end
  end

  private
    def already_registered_card
      if current_user.card?
        redirect_to card_path, alert: "既にカード登録済みです"
      end
    end
end
