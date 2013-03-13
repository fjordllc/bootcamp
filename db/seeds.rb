require 'seed_helper'

include SeedHelper

User.delete_all
Practice.delete_all

User.create!(
  login_name: 'test',
  name: 'hoge',
  email: 'hoge@hoge.com',
  password: 'test',
  password_confirmation: 'test'
)

import_fixture 'practices'
