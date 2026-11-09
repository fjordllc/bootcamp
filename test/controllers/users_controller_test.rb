# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'GET new rejects the shared legacy TOKEN even when it matches' do
    mock_env('TOKEN' => 'registration-test-token') do
      get new_user_path, params: { role: 'mentor', token: 'registration-test-token' }
    end

    assert_redirected_to root_path
  end

  test 'GET new accepts scoped signed claims' do
    token = signed_invitation_token
    get new_user_path, params: invitation_query(token)

    assert_response :success
    assert_select 'input[name="invitation_role"][value="trainee_invoice_payment"]'
    assert_not_includes response.body, token
  end

  { role: 'mentor', company_id: :company2, course_id: :course2 }.each do |attribute, value|
    test "GET new rejects changed signed invitation #{attribute}" do
      replacement = case attribute
                    when :company_id then companies(value).id
                    when :course_id then courses(value).id
                    else value
                    end
      get new_user_path, params: invitation_query(signed_invitation_token).merge(attribute => replacement)

      assert_redirected_to root_path
    end
  end

  test 'GET new rejects expired signed claims' do
    token = signed_invitation_token
    travel 31.days do
      get new_user_path, params: invitation_query(token)
      assert_redirected_to root_path
    end
  end

  test 'GET new uses signed claims when redundant query attributes are omitted' do
    get new_user_path, params: { token: signed_invitation_token }

    assert_response :success
    assert_select 'input[name="invitation_role"][value="trainee_invoice_payment"]'
    assert_select 'input[name="user[company_id]"]', value: companies(:company1).id.to_s
    assert_select 'input[name="user[course_id]"]', value: courses(:course1).id.to_s
  end

  test 'GET new rejects tampered tokens and tokens for another purpose' do
    wrong_purpose = Rails.application.message_verifier(:registration_invitation).generate(
      { 'role' => 'mentor' }, purpose: :another_invitation, expires_in: 30.days
    )
    ["#{signed_invitation_token}tampered", wrong_purpose].each do |token|
      get new_user_path, params: { role: 'mentor', token: }
      assert_redirected_to root_path
    end
  end

  test 'POST revalidates invitation expiration before initial submission' do
    get new_user_path, params: invitation_query(signed_invitation_token)
    assert_response :success

    travel 31.days do
      with_registration_services do
        assert_no_difference 'User.count' do
          post users_path, params: { invitation_role: 'trainee_invoice_payment', user: registration_attributes.merge(invoice_payment: '1') }
        end
      end
      assert_redirected_to root_path
    end
  end

  test 'adviser dashboard invitation grants adviser only for their own company' do
    sign_in :senpai
    get root_path
    link = css_select('a').find { |node| node.text.include?('社内メンター招待リンク') }['href']
    query = Rack::Utils.parse_query(URI.parse(link).query)
    assert_equal({ 'role' => 'adviser', 'company_id' => users(:senpai).company_id.to_s }, RegistrationInvitation.verify(query.fetch('token')))
    sign_out
    get new_user_path, params: query
    assert_response :success

    with_registration_services do
      assert_difference 'User.count', 1 do
        post users_path, params: { invitation_role: 'adviser', user: registration_attributes.merge(company_id: users(:senpai).company_id) }
      end
    end
    user = User.find_by!(email: registration_attributes[:email])
    assert_predicate user, :adviser?
    assert_equal users(:senpai).company, user.company

    get new_user_path, params: query.merge('company_id' => companies(:company1).id)
    assert_redirected_to root_path
  end

  test 'POST retry revalidates invitation expiration after failed input' do
    token = signed_invitation_token
    get new_user_path, params: invitation_query(token)
    assert_response :success
    attributes = registration_attributes.merge(invoice_payment: '1')

    with_registration_services do
      assert_no_difference 'User.count' do
        post users_path, params: { invitation_role: 'trainee_invoice_payment', user: attributes.merge(name: '') }
      end
      assert_response :success

      travel 31.days do
        assert_no_difference 'User.count' do
          post users_path, params: { invitation_role: 'trainee_invoice_payment', user: attributes }
        end
        assert_redirected_to root_path
      end
    end
  end

  %w[mentor adviser trainee].each do |role|
    test "POST create cannot grant #{role} from public flags" do
      with_registration_services do
        assert_difference 'User.count', 1 do
          post users_path, params: { user: registration_attributes.merge(role => 'true') }
        end
      end

      user = User.find_by!(email: registration_attributes[:email])
      assert_predicate user, :student?
      assert_equal 'fake_customer_0123456789', user.customer_id
      assert_equal 'fake_subscription_0123456789', user.subscription_id
      assert_redirected_to created_users_url(role: 'student')
    end
  end

  [nil, '', ' ', 'incorrect-token'].each do |token|
    test "GET new rejects invitation with #{token.inspect} token" do
      mock_env('TOKEN' => 'registration-test-token') do
        get new_user_path, params: { role: 'mentor', token: }
      end

      assert_redirected_to root_path
    end

    test "POST create rejects invitation with #{token.inspect} token" do
      with_registration_services do
        mock_env('TOKEN' => 'registration-test-token') do
          assert_no_difference 'User.count' do
            post users_path, params: { role: 'mentor', token:, user: registration_attributes.merge(mentor: 'true') }
          end
        end
      end

      assert_redirected_to root_path
    end
  end

  [nil, '', ' '].each do |configured_token|
    test "GET new rejects invitation when configured token is #{configured_token.inspect}" do
      mock_env('TOKEN' => configured_token) do
        get new_user_path, params: { role: 'mentor', token: configured_token }
      end

      assert_redirected_to root_path
    end
  end

  test 'GET new rejects unknown invitation role' do
    mock_env('TOKEN' => 'registration-test-token') do
      get new_user_path, params: { role: 'admin', token: 'registration-test-token' }
    end

    assert_redirected_to root_path
  end

  test 'POST create rejects a nested invitation role without validated context' do
    with_registration_services do
      assert_no_difference 'User.count' do
        post users_path, params: { user: registration_attributes.merge(role: 'trainee_invoice_payment', trainee: 'true', invoice_payment: '1') }
      end
    end

    assert_redirected_to root_path
  end

  %w[mentor adviser trainee_invoice_payment trainee_credit_card_payment trainee_select_a_payment_method].each do |role|
    test "validated #{role} invitation assigns only the invited role" do
      visit_invitation(role)
      assert_response :success
      assert_select 'input[name=token]', count: 0
      assert_not_includes response.body, @invitation_token

      with_registration_services do
        assert_difference 'User.count', 1 do
          post users_path, params: {
            invitation_role: role,
            user: registration_attributes.merge(role:, mentor: 'true', adviser: 'true', trainee: 'true',
                                                invoice_payment: role != 'trainee_credit_card_payment'),
            credit_card_payment: role == 'trainee_credit_card_payment' ? '1' : nil
          }
        end
      end

      user = User.find_by!(email: registration_attributes[:email])
      assert_equal role == 'mentor', user.mentor?
      assert_equal role == 'adviser', user.adviser?
      assert_equal role.start_with?('trainee'), user.trainee?
      assert_equal companies(:company1), user.company
      assert_equal courses(:course1), user.course
      assert_nil user.customer_id
    end
  end

  { role: 'mentor', company_id: 'another-company', course_id: 'another-course' }.each do |attribute, value|
    test "POST create rejects changed invitation #{attribute}" do
      visit_invitation('trainee_invoice_payment')

      with_registration_services do
        assert_no_difference 'User.count' do
          attributes = registration_attributes.merge(role: 'trainee_invoice_payment', trainee: 'true', invoice_payment: '1')
          post users_path, params: { invitation_role: 'trainee_invoice_payment', user: attributes.merge(attribute => value) }
        end
      end

      assert_redirected_to root_path
    end
  end

  test 'ordinary signup page clears previous invitation context' do
    visit_invitation('mentor')
    get new_user_path
    assert_response :success

    with_registration_services do
      assert_difference 'User.count', 1 do
        post users_path, params: { user: registration_attributes }
      end
    end

    assert_predicate User.find_by!(email: registration_attributes[:email]), :student?
  end

  test 'legacy trainee invitation supports choosing a payment method' do
    visit_invitation('trainee')
    assert_response :success
    assert_select 'input[name="invitation_role"][value="trainee_select_a_payment_method"]'

    with_registration_services do
      assert_difference 'User.count', 1 do
        post users_path, params: { invitation_role: 'trainee_select_a_payment_method', credit_card_payment: '1', user: registration_attributes }
      end
    end

    user = User.find_by!(email: registration_attributes[:email])
    assert_predicate user, :trainee?
    assert_not user.invoice_payment?
    assert_nil user.customer_id
  end

  test 'invitation permits company and course selection when omitted from URL' do
    visit_invitation('trainee_invoice_payment', company_id: nil, course_id: nil)
    attributes = registration_attributes.merge(company_id: companies(:company2).id, course_id: courses(:course2).id, invoice_payment: '1')

    with_registration_services do
      assert_difference 'User.count', 1 do
        post users_path, params: { invitation_role: 'trainee_invoice_payment', user: attributes }
      end
    end

    user = User.find_by!(email: attributes[:email])
    assert_predicate user, :trainee?
    assert_equal companies(:company2), user.company
    assert_equal courses(:course2), user.course
    assert_predicate user, :invoice_payment?
  end

  test 'POST create uses bound company and course when hidden fields are omitted' do
    visit_invitation('adviser')

    with_registration_services do
      assert_difference 'User.count', 1 do
        post users_path, params: { invitation_role: 'adviser', user: registration_attributes.except(:company_id, :course_id) }
      end
    end

    user = User.find_by!(email: registration_attributes[:email])
    assert_predicate user, :adviser?
    assert_equal companies(:company1), user.company
    assert_equal courses(:course1), user.course
  end

  test 'invalid invitation page clears previous invitation context' do
    visit_invitation('mentor')
    get new_user_path, params: { role: 'adviser' }
    assert_redirected_to root_path

    with_registration_services do
      assert_no_difference 'User.count' do
        post users_path, params: { invitation_role: 'mentor', user: registration_attributes }
      end
    end

    assert_redirected_to root_path
  end

  test 'old signup form cannot adopt a different invitation in the session' do
    visit_invitation('mentor')
    visit_invitation('adviser')

    with_registration_services do
      assert_no_difference 'User.count' do
        post users_path, params: { invitation_role: 'mentor', user: registration_attributes }
      end
    end

    assert_redirected_to root_path
  end

  test 'invited POST requires visiting the validated invitation even with a correct token' do
    with_registration_services do
      assert_no_difference 'User.count' do
        post users_path, params: { role: 'mentor', token: RegistrationInvitation.generate(role: 'mentor'), user: registration_attributes }
      end
    end

    assert_redirected_to root_path
  end

  test 'invitation authorization survives a validation failure' do
    visit_invitation('trainee_invoice_payment')
    attributes = registration_attributes.merge(role: 'trainee_invoice_payment', invoice_payment: '1')

    with_registration_services do
      assert_no_difference 'User.count' do
        post users_path, params: { invitation_role: 'trainee_invoice_payment', user: attributes.merge(name: '') }
      end
      assert_response :success
      assert_select 'input[name="user[role]"][value="trainee_invoice_payment"]'
      assert_select 'input[name="user[company_id]"]', value: companies(:company1).id.to_s
      assert_not_includes response.body, @invitation_token

      assert_difference 'User.count', 1 do
        post users_path, params: { invitation_role: 'trainee_invoice_payment', user: attributes }
      end
    end

    assert_redirected_to created_users_url(role: 'trainee')
    assert_predicate User.find_by!(email: attributes[:email]), :trainee?

    with_registration_services do
      assert_no_difference 'User.count' do
        post users_path,
             params: { invitation_role: 'trainee_invoice_payment', user: attributes.merge(login_name: 'another-user', email: 'another@example.com') }
      end
    end

    assert_redirected_to root_path
  end

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
    assert_redirected_to created_users_url(role: 'student')

    student = User.find_by(login_name: 'Piyopiyo-student')
    assert_not_nil student.discord_profile.times_id
  end

  test 'POST create by trainee' do
    visit_invitation('trainee_invoice_payment', company_id: '123456789', course_id: nil)
    mock_env('DISCORD_GUILD_ID' => '222') do
      Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
        assert_difference 'User.trainees.count', 1 do
          post users_path,
               params: {
                 invitation_role: 'trainee_invoice_payment',
                 user: {
                   invoice_payment: '1',
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
    assert_redirected_to created_users_url(role: 'trainee')

    trainee = User.find_by(login_name: 'Piyopiyo-trainee')
    assert_not_nil trainee.discord_profile.times_id
  end

  test 'POST create by adviser' do
    visit_invitation('adviser', company_id: '123456789', course_id: nil)
    Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
      assert_difference 'User.advisers.count', 1 do
        post users_path,
             params: {
               invitation_role: 'adviser',
               user: {
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
    assert_redirected_to created_users_url(role: 'adviser')

    adviser = User.find_by(login_name: 'Piyopiyo-adviser')
    assert_nil adviser.discord_profile.times_id
  end

  test 'GET created for student' do
    get created_users_path(role: 'student')
    assert_response :success
    assert_includes response.body, 'FBC参加登録完了'
    assert_includes response.body, '参加登録が完了しました'
  end

  test 'GET created for adviser' do
    get created_users_path(role: 'adviser')
    assert_response :success
    assert_includes response.body, 'FBCアドバイザー参加登録完了'
    assert_includes response.body, 'アドバイザー登録が完了しました'
  end

  test 'GET created for trainee' do
    get created_users_path(role: 'trainee')
    assert_response :success
    assert_includes response.body, 'FBC研修生参加登録完了'
    assert_includes response.body, '研修生登録が完了しました'
  end

  test 'GET created for mentor' do
    get created_users_path(role: 'mentor')
    assert_response :success
    assert_includes response.body, 'FBCメンター参加登録完了'
    assert_includes response.body, 'メンター登録が完了しました'
  end

  test 'GET created without role defaults to student' do
    get created_users_path
    assert_response :success
    assert_includes response.body, 'FBC参加登録完了'
    assert_includes response.body, '参加登録が完了しました'
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

  private

  def signed_invitation_token
    Rails.application.message_verifier(:registration_invitation).generate(
      { 'role' => 'trainee_invoice_payment', 'company_id' => companies(:company1).id.to_s, 'course_id' => courses(:course1).id.to_s },
      purpose: :registration_invitation, expires_in: 30.days
    )
  end

  def invitation_query(token)
    { role: 'trainee_invoice_payment', company_id: companies(:company1).id, course_id: courses(:course1).id, token: }
  end

  def registration_attributes
    {
      login_name: 'invited-user', email: 'invited-user@example.com',
      name: '招待 太郎', name_kana: 'ショウタイ タロウ', description: 'よろしくお願いします。',
      job: 'office_worker', os: 'linux', company_id: companies(:company1).id,
      course_id: courses(:course1).id, password: 'passW0rd1234', password_confirmation: 'passW0rd1234'
    }
  end

  def visit_invitation(role, **attributes)
    selections = { company_id: companies(:company1).id, course_id: courses(:course1).id }.merge(attributes)
    @invitation_token = RegistrationInvitation.generate(role:, **selections)
    get new_user_path, params: { role:, token: @invitation_token, **selections }
  end

  def with_registration_services(&block)
    Card.stub(:new, -> { FakeCard.new }) do
      Subscription.stub(:new, -> { FakeSubscription.new }) do
        Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }, &block)
      end
    end
  end
end
