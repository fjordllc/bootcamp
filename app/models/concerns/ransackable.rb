# frozen_string_literal: true

module Ransackable
  extend ActiveSupport::Concern

  class_methods do
    def ransackable_attributes(_auth_object = nil)
      %w[
        login_name name name_kana email twitter_account facebook_url
        blog_url github_account description profile_text
        created_at updated_at last_activity_at
        company_id course_id graduated_on retired_on
        admin mentor adviser trainee job_seeker hibernated_at
        experiences career_path job os editor subdivision_code country_code
      ]
    end

    def ransackable_scopes(_auth_object = nil)
      %i[job_seeking]
    end

    def ransackable_associations(_auth_object = nil)
      %w[company course discord_profile]
    end
  end
end
