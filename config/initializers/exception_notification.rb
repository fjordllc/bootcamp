Interns::Application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => "[interns] ",
    :sender_address => %{"notifier" <notifier@fjord.jp>},
    :exception_recipients => %w{develop@fjord.jp}
  }
