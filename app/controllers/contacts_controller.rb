class ContactsController < ApplicationController
  def index
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      NoticeMailer.contact_email(@contact).deliver_later
      redirect_to root_path, notice: t("contact_was_successfully_created")
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
        :occupation_cd,
        :division,
        :location_cd,
        :has_mac_cd,
        :work_time,
        :work_days,
        :programming_experience_cd,
        :twitter_url,
        :facebook_url,
        :blog_url,
        :github_account,
        :application_reason,
        :purpose_deadline_year,
        :purpose_deadline_month,
        :purpose_content,
        :user_policy_agreed,
      )
    end
end
