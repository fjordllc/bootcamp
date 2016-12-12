class ContactsController < ApplicationController
  def index
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to @contact, notice: t('contact_was_successfully_created')
    else
      render :new
    end
  end

  private

  def contact_params
    params.require(:contact).permit(
      :name,
      :name_phonetic,
      :email,
      :occupation,
      :division,
      :work_place,
      :has_mac,
      :work_time,
      :work_days,
      :programming_experience,
      :twitter_url,
      :facebook_url,
      :blog_url,
      :github_account,
      :application_reason,
      :user_policy_agreed,
    )
  end
end
