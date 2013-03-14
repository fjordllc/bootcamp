require 'seed_helper'

include SeedHelper

User.delete_all
Practice.delete_all

User.create!(
  login_name: 'komagata',
  first_name: 'Masaki',
  last_name: 'Komagata',
  email: 'komagata@gmail.com',
  password: 'testtest',
  password_confirmation: 'testtest'
)

User.create!(
  login_name: 'machida',
  first_name: 'Teppei',
  last_name: 'machida',
  email: 'machidanohimitsu@gmail.com',
  password: 'testtest',
  password_confirmation: 'testtest'
)

import_fixture 'practices'
