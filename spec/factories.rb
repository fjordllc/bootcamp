FactoryGirl.define do
  sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:login_name) { |n| "user#{n}" }

  factory :user do
    login_name
    email
    first_name 'Hiroshi'
    last_name  'Yoshida'
    password   'testtest'
    password_confirmation { |u| u.password }

    trait :programmer do
      job_cd 0
    end

    trait :designer do
      job_cd 1
    end

    trait :with_started_practices_for_programmer do
      after(:create) do |user|
        FactoryGirl.create_list(:active_learnings_for_programmer, 10, user: user)
      end
    end

    trait :with_finished_all_practices_for_programmer do
      after(:create) do |user|
        FactoryGirl.create_list(:completed_learnings_for_programmer, 10, user: user)
      end
    end

    trait :with_finished_practices_for_programmer do
      after(:create) do |user|
        FactoryGirl.create_list(:completed_learnings_for_programmer, 5, user: user)
        FactoryGirl.create_list(:active_learnings_for_programmer, 5, user: user)
      end
    end

    trait :with_started_practices_for_designer do
      after(:create) do |user|
        FactoryGirl.create_list(:active_learnings_for_designer, 10, user: user)
      end
    end

    trait :with_finished_practices_for_designer do
      after(:create) do |user|
        FactoryGirl.create_list(:completed_learnings_for_designer, 10, user: user)
      end
    end

    factory :programmer_with_started_practices,
      traits: [:programmer, :with_started_practices_for_programmer]
    factory :programmer_with_finished_all_practices,
      traits: [:programmer, :with_finished_all_practices_for_programmer]
    factory :programmer_with_finished_practices,
      traits: [:programmer, :with_finished_practices_for_programmer]
    factory :designer_with_started_practices,
      traits: [:designer, :with_started_practices_for_designer]
    factory :designer_with_finished_practices,
      traits: [:designer, :with_finished_practices_for_designer]
  end

  factory :practice do
    title 'Title'
    description 'description....'
    goal 'goal....'
    target_cd 0

    trait :for_programmer do
      target_cd 1
    end

    trait :for_designer do
      target_cd 2
    end

    factory :practice_for_programmer, traits: [:for_programmer]
    factory :practice_for_designer, traits: [:for_designer]
  end

  factory :learning do
    user
    practice

    trait :started do
      status_cd 0
    end

    trait :completed do
      status_cd 1
    end

    trait :for_programmer do
      association :practice, factory: :practice_for_programmer
    end

    trait :for_designer do
      association :practice, factory: :practice_for_designer
    end

    factory :active_learnings_for_programmer,
      traits: [:started, :for_programmer]
    factory :completed_learnings_for_programmer,
      traits: [:completed, :for_programmer]
    factory :active_learnings_for_designer,
      traits: [:started, :for_designer]
    factory :completed_learnings_for_designer,
      traits: [:completed, :for_designer]
  end
end
