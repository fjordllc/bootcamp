# frozen_string_literal: true

class CardController < ApplicationController
  before_action :require_login

  def show
    @card = current_user.card
  end

  def new
  end

  def create
    begin
      token = params[:idempotency_token]
      customer = Card.create(current_user, params[:stripeToken], token)
      subscription = Subscription.create(customer["id"], "#{token}-subscription")
      current_user.customer_id = customer["id"]
      current_user.save(validate: false)

      flash[:notice] = "カードを登録しました。"
      logger.info "[Payment] カードを登録しました。"
    rescue Stripe::CardError => e
      current_user.customer_id = nil
      current_user.save(validate: false)
      flash[:alert] = "カード情報に不備があります。：#{e.message}"
      logger.warn "[Payment] カード情報に不備があります。：#{e.message}"
    rescue => e
      current_user.customer_id = nil
      current_user.save(validate: false)
      flash[:alert] = "カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
      logger.warn "[Payment] カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
    end

    if flash[:alert]
      redirect_to new_card_url
    else
      redirect_to card_url
    end
  end

  def edit
  end

  def update
    begin
      Card.update(current_user.customer_id, params[:stripeToken])

      flash[:notice] = "カードを編集しました。"
      logger.info "[Payment] カードを編集しました。"
    rescue Stripe::CardError => e
      current_user.customer_id = nil
      current_user.save(validate: false)
      flash[:alert] = "カード情報に不備があります。：#{e.message}"
      logger.warn "[Payment] カード情報に不備があります。：#{e.message}"
    rescue => e
      current_user.customer_id = nil
      current_user.save(validate: false)
      flash[:alert] = "カード編集に失敗しました。運営会社までお問い合わせください。：#{e.message}"
      logger.warn "[Payment] カード編集に失敗しました。運営会社までお問い合わせください。：#{e.message}"
    end

    if flash[:alert]
      redirect_to edit_card_url
    else
      redirect_to card_url
    end
  end
end
