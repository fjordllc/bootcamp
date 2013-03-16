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
  password_confirmation: 'testtest',
  job_cd: 0
)

User.create!(
  login_name: 'machida',
  first_name: 'Teppei',
  last_name: 'Machida',
  email: 'machidanohimitsu@gmail.com',
  password: 'testtest',
  password_confirmation: 'testtest',
  job_cd: 1
)

import_fixture 'practices'
