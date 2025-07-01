# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

module Discord
  class UsersControllerTest < ActionDispatch::IntegrationTest
    include MockEnvHelper

    test 'POST create by student' do
      mock_env('DISCORD_GUILD_ID' => '111') do
        Card.stub(:new, -> { FakeCard.new }) do
          Subscription.stub(:new, -> { FakeSubscription.new }) do
            Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
              assert_difference 'User.students.count', 1 do
                post users_path,
                     params: {
                       user: {
                         adviser: 'false',
                         trainee: 'false',
                         company_id: '',
                         login_name: 'Piyopiyo-student',
                         email: 'piyopiyo-student@example.com',
                         name: '現役生です',
                         name_kana: 'ゲンエキセイデス',
                         description: '現役生と言います。よろしくお願いします。',
                         job: 'part_time_worker',
                         os: 'linux',
                         experiences: 0,
                         password: 'passW0rd1234',
                         password_confirmation: 'passW0rd1234',
                         coc: 1,
                         tos: 2
                       }
                     }
              end
            end
          end
        end
      end
      assert_redirected_to root_url

      student = User.find_by(login_name: 'Piyopiyo-student')
      assert_not_nil student.discord_profile.times_id
    end

    test 'POST create by trainee' do
      mock_env('DISCORD_GUILD_ID' => '222') do
        Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
          assert_difference 'User.trainees.count', 1 do
            post users_path,
                 params: {
                   user: {
                     adviser: 'false',
                     trainee: 'true',
                     company_id: '123456789',
                     login_name: 'Piyopiyo-trainee',
                     email: 'piyopiyo-trainee@example.com',
                     name: '研修生です',
                     name_kana: 'ケンシュウセイデス',
                     description: '研修生と言います。よろしくお願いします。',
                     job: 'office_worker',
                     os: 'windows_wsl2',
                     experiences: 2,
                     password: 'passW0rd1234',
                     password_confirmation: 'passW0rd1234',
                     coc: 1,
                     tos: 2
                   }
                 }
          end
        end
      end
      assert_redirected_to root_url

      trainee = User.find_by(login_name: 'Piyopiyo-trainee')
      assert_not_nil trainee.discord_profile.times_id
    end

    test 'POST create by adviser' do
      Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
        assert_difference 'User.advisers.count', 1 do
          post users_path,
               params: {
                 user: {
                   adviser: 'true',
                   trainee: 'false',
                   company_id: '123456789',
                   login_name: 'Piyopiyo-adviser',
                   email: 'piyopiyo-adviser@example.com',
                   name: 'アドバイザーです',
                   name_kana: 'アドバイザーデス',
                   description: 'アドバイザーと言います。よろしくお願いします。',
                   password: 'passW0rd1234',
                   password_confirmation: 'passW0rd1234',
                   coc: 1,
                   tos: 2
                 }
               }
        end
      end
      assert_redirected_to root_url

      adviser = User.find_by(login_name: 'Piyopiyo-adviser')
      assert_nil adviser.discord_profile.times_id
    end

    class FakeCard
      def search(*)
        nil
      end

      def create(*)
        {
          id: 'fake_customer_0123456789'
        }.stringify_keys
      end
    end

    class FakeSubscription
      def create(*)
        {
          id: 'fake_subscription_0123456789'
        }.stringify_keys
      end
    end

    class ValidTimesChannel
      def save
        true
      end

      def id
        '1234567890123456789'
      end
    end
  end
end
