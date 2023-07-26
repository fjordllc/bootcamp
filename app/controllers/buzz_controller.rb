# frozen_string_literal: true

class BuzzController < ApplicationController
  before_action :set_buzz
  skip_before_action :require_active_user_login, raise: false, only: %i[show]
  before_action :require_admin_or_mentor_login, except: %i[show]

  def show
    render layout: 'welcome'
  end

  def edit; end

  def update
    if @buzz.update(buzz_params)
      redirect_to buzz_path, notice: '紹介記事を更新しました'
    else
      render :edit
    end
  end

  private

  def set_buzz
    @set_buzz ||= begin
      buzz = Buzz.first
      buzz ||= Buzz.create(body: 'インターネットで見つけたフィヨルドブートキャンプに関連する記事、フィヨルドブートキャンプに言及いただいら記事を集めています。このページに載せて欲しい記事、掲載NGな記事がありましたら[お問い合わせフォーム](https://bootcamp.fjord.jp/inquiry/new)からご連絡ください。')
    end
    @buzz = @set_buzz
  end

  def buzz_params
    params.require(:buzz).permit(:body)
  end
end
