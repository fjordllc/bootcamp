# frozen_string_literal: true

class UserRegister
  def initialize(user)
    @user = user
  end

  def create(params)
    @user = User.new(params)
    @user.company = Company.first
    @user.course = Course.first
    @user.save

    unless @user.adviser?
      begin
        customer = Card.create(@user, params[:stripeToken])
        @user.update(customer_id: customer["id"])
        Subscription.create(customer["id"])
      rescue Stripe::CardError => e
        @user.update(customer_id: nil)
        @user.errors.add(:customer_id, "カード情報に不備があります。：#{e.message}")
        logger.warn "[Payment] カード情報に不備があります。：#{e.message}"
      rescue => e
        @user.update(customer_id: nil)
        @user.errors.add(:customer_id, "カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}")
        logger.warn "[Payment] カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
      end
    end

    @user
  end
end
