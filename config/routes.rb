# frozen_string_literal: true

Rails.application.routes.draw do
  mount Switchlet::Engine => "/switchlet"
  
  root to: "home#index"

  get "test", to: "home#test", as: "test"
  get "welcome", to: "welcome#index", as: "welcome"
  get "practices", to: "welcome#practices", as: "practices"
  get "pricing", to: "welcome#pricing", as: "pricing"
  get "alumni_voices", to: "welcome#alumni_voices", as: "alumni_voices"
  get "training", to: "welcome#training", as: "training"
  get "faq", to: "welcome#faq", as: "faq"
  get "job_support", to: "welcome#job_support", as: "job_support"
  get "tos", to: "welcome#tos", as: "tos"
  get "pp", to: "welcome#pp", as: "pp"
  get "law", to: "welcome#law", as: "law"
  get "coc", to: "welcome#coc", as: "coc"
  get "press_kit", to: "welcome#press_kit", as: "press_kit"
  get "logo", to: "welcome#logo", as: "logo"
  get 'certified_reskill_courses/rails_developer_course',
    to: 'welcome#rails_developer_course',
    as: :certified_reskill_courses_rails_developer_course_root
  get 'choose_courses', to: "welcome#choose_courses", as: "choose_courses"
  draw :scheduler
  draw :api
  draw :paper
  draw :admin
  draw :mentor
  draw :current_user
  draw :partial
  draw :users
  draw :connection
  draw :products
  draw :reports
  resources :announcements
  resource :training_completion, only: %i(show new create), controller: "training_completion"
  resource :retirement, only: %i(show new create), controller: "retirement"
  resources :request_retirements, only: %i(show new create)
  resource :hibernation, only: %i(show new create), controller: "hibernation"
  resource :comeback, only: %i(new create), controller: "comeback"
  resource :current_user, only: %i(edit update), controller: "current_user" do
    resource :password, only: %i(edit update), controller: "current_user/password"
  end
  resources :searchables, only: %i(index)
  resources :user_sessions, only: %i(new create destroy)
  resources :password_resets, only: %i(create edit update)
  resources :courses, only: %i(index) do
    resources :practices, only: %i(index), controller: "courses/practices"
    resources :books, only: %i(index), controller: "courses/books"
  end
  resources :practices, only: %i(show) do
    resources :reports, only: %i(index), controller: "practices/reports"
    resources :questions, only: %i(index), controller: "practices/questions"
    resources :products, only: %i(index), controller: "practices/products"
    resources :pages, only: %i(index), controller: "practices/pages"
    resource :completion, only: %i(show), controller: "practices/completion"
    resource :submission_answer, only: %i(show), controller: "practices/submission_answer"
    resources :coding_tests, only: %i(index), controller: "practices/coding_tests"
    resources :movies, only: %i(index), controller: "practices/movies"
  end
  resources :coding_tests, only: %i(show) do
    resources :coding_test_submissions,
      only: %i(index show show),
      controller: "coding_tests/coding_test_submissions"
  end
  resources :pages, param: :slug_or_id
  namespace :notification do
    resource :redirector, only: %i(show), controller: "redirector"
  end
  resources :notifications, only: %i(index show) do
    collection do
      resources :allmarks, only: %i(create), controller: "notifications/allmarks"
      resource :read_by_category, only: %i(create), controller: "notifications/read_by_category"
    end
  end
  resources :works, except: %i(index)
  namespace :talks do
    resources :action_uncompleted, only: %i(index)
  end
  resources :talks, only: %i(index show)
  resources :questions
  resources :courses, only: :index
  resource :inquiry, only: %i(new create)
  resource :corporate_training_inquiry, only: %i(new create)
  namespace :articles do
    resources :wips, only: %i(index), controller: "wips"
  end
  resources :articles
  namespace :events do
    resources :calendars, only: %i(index)
  end
  resources :events do
    resources :participations, only: %i(create destroy), controller: "events/participations"
  end
  resources :regular_events do
    resources :participations, only: %i(create destroy), controller: "regular_events/participations"
  end
  resources :companies, only: %i(index show) do
    resources :users, only: %i(index), controller: "companies/users"
    resources :reports, only: %i(index), controller: "companies/reports"
    resources :products, only: %i(index), controller: "companies/products"
  end
  namespace :stripe do
    resource :webhook, only: %i(create)
  end
  resources :books, except: %i(show)
  resources :generations, only: %i(show index)
  resource :billing_portal, only: :create, controller: "billing_portal"
  resources :external_entries, only: %i(index)
  resources :surveys, only: %i(show) do
    resources :survey_answers, only: %i(create), controller: "surveys/survey_answers"
  end
  resources :grant_course_applications, only: %i(new create) do
    collection do
      get :created
    end
  end
  resources :press_releases, only: %i(index)
  get "articles/tags/:tag", to: "articles#index", as: :tag, tag: /.+/
  get 'sponsorships', to: 'articles/sponsorships#index'
  get "pages/tags/:tag", to: "pages#index", as: :pages_tag, tag: /.+/, format: "html"
  get "questions/tags/:tag", to: "questions#index", as: :questions_tag, tag: /.+/, format: "html"
  get "movies/tags/:tag", to: "movies#index", as: :movies_tag, tag: /.+/, format: "html"
  get "login" => "user_sessions#new", as: :login
  get "auth/:provider/callback" => "user_sessions#callback"
  get 'auth/failure', to: "user_sessions#failure"
  post "user_sessions" => "user_sessions#create"
  get "logout" => "user_sessions#destroy", as: :logout
  get "portfolios" => "works#index"
  niconico_calendar_constraints = { niconico_calendar: /\d{4}-\d{2}/ }
  get '/', to: 'home#index', as: :niconico_calendar_date, constraints: niconico_calendar_constraints
  get '/users/:id', to: 'users#show', as: :niconico_calendar_date_in_profile, constraints: niconico_calendar_constraints
  get "buzzes/years/:year", to: "buzzes#index", as: :buzzes_year, constraints: { year: /\d{4}/ }
  resources :buzzes, only: %i[index]
  resources :movies
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  mount GoodJob::Engine => 'good_job'
end
