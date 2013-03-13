require 'seed_helper'

include SeedHelper

User.delete_all
Practice.delete_all

User.create!(
  login_name: 'test',
  name: '駒形真幸',
  name_kana: 'コマガタマサキ',
  email: 'komagata@gmail.com',
  password: 'testtest',
  password_confirmation: 'testtest'
)

import_fixture 'practices'
