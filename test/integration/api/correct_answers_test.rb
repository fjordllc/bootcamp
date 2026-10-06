# frozen_string_literal: true

require 'test_helper'

class API::CorrectAnswersTest < ActionDispatch::IntegrationTest
  setup do
    @question = questions(:question8)
    @answer = @question.answers.create!(user: users(:hajime), description: '回答です。')
    @application = Doorkeeper::Application.create!(
      name: 'Correct Answer Test Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end

  %i[create update].each do |action|
    %i[kimura adminonly mentormentaro].each do |actor|
      test "#{actor} can #{action} correct answer with OAuth write scope" do
        prepare_answer(action)

        assert_successful_mutation(action, headers: oauth_headers(actor, 'read write'))
      end
    end

    %i[hajime advijirou].each do |actor|
      test "#{actor} cannot #{action} another user's correct answer with OAuth write scope" do
        prepare_answer(action)

        assert_rejected_mutation(action, :forbidden, headers: oauth_headers(actor, 'read write'))
      end
    end

    %i[kimura adminonly].each do |actor|
      test "#{actor} cannot #{action} correct answer with OAuth read scope" do
        prepare_answer(action)

        assert_rejected_mutation(action, :forbidden, headers: oauth_headers(actor, 'read'))
        assert_equal 'invalid_scope', response.parsed_body['error']
      end
    end

    test "adviser who authored the question can #{action} correct answer" do
      @question.update!(user: users(:advijirou))
      prepare_answer(action)

      assert_successful_mutation(action, headers: oauth_headers(:advijirou, 'read write'))
    end

    test "unauthenticated user cannot #{action} correct answer" do
      prepare_answer(action)

      assert_rejected_mutation(action, :unauthorized)
    end

    test "question author can #{action} correct answer using JWT without a session" do
      prepare_answer(action)
      token = create_token('kimura', 'testtest')
      assert_response :ok
      assert_predicate token, :present?
      reset!

      assert_successful_mutation(action, headers: { Authorization: "Bearer #{token}" })
    end

    test "answer author cannot #{action} another user's correct answer using JWT" do
      prepare_answer(action)
      token = create_token('hajime', 'testtest')
      assert_response :ok
      assert_predicate token, :present?
      reset!

      assert_rejected_mutation(action, :forbidden, headers: { Authorization: "Bearer #{token}" })
    end

    test "question author can #{action} correct answer using a browser session" do
      prepare_answer(action)
      sign_in(:kimura)

      assert_successful_mutation(action)
    end

    test "adviser cannot #{action} another user's correct answer using a browser session" do
      prepare_answer(action)
      sign_in(:advijirou)

      assert_rejected_mutation(action, :forbidden)
    end

    test "#{action} rejects an answer belonging to another question" do
      prepare_answer(action)

      assert_rejected_mutation(action, :not_found,
                               headers: oauth_headers(:adminonly, 'read write'),
                               answer_id: answers(:answer1).id)
    end

    test "#{action} returns not found for a missing answer" do
      prepare_answer(action)

      assert_rejected_mutation(action, :not_found,
                               headers: oauth_headers(:kimura, 'read write'), answer_id: 0)
    end

    test "#{action} returns not found for a missing question" do
      prepare_answer(action)

      assert_rejected_mutation(action, :not_found,
                               headers: oauth_headers(:adminonly, 'read write'), question_id: 0)
    end
  end

  private

  def prepare_answer(action)
    return unless action == :update

    @answer = @answer.becomes!(CorrectAnswer)
    @answer.save!
  end

  def oauth_headers(actor, scopes)
    token = Doorkeeper::AccessToken.create!(
      application: @application, resource_owner_id: users(actor).id, scopes:
    )
    { Authorization: "Bearer #{token.token}" }
  end

  def mutate(action, headers: {}, answer_id: @answer.id, question_id: @question.id)
    method = action == :create ? :post : :patch
    public_send(method, api_answer_correct_answer_path(answer_id),
                params: { question_id: }, headers:, as: :json)
  end

  def capture_mutation_events(&block)
    events = []
    subscriber = ->(name, _start, _finish, _id, payload) { events << [name, payload] }
    ActiveSupport::Notifications.subscribed(subscriber, /\A(?:answer|correct_answer)\.save\z/, &block)
    events
  end

  def assert_rejected_mutation(action, status, **options)
    before_answers = Answer.order(:id).pluck(:id, :type, :question_id, :updated_at)
    before_correct_answer = @question.reload.correct_answer&.id
    events = capture_mutation_events { mutate(action, **options) }

    assert_response status
    assert_equal before_answers, Answer.order(:id).pluck(:id, :type, :question_id, :updated_at)
    assert_equal [before_correct_answer], [@question.reload.correct_answer&.id]
    assert_empty events
  end

  def assert_successful_mutation(action, **options)
    events = capture_mutation_events { mutate(action, **options) }

    assert_response(action == :create ? :ok : :no_content)
    answer = Answer.find(@answer.id)
    if action == :create
      assert_instance_of CorrectAnswer, answer
      assert_equal @answer.id, @question.reload.correct_answer.id
      assert_equal %w[answer.save correct_answer.save], events.map(&:first)
    else
      assert_instance_of Answer, answer
      assert_nil answer.type
      assert_nil @question.reload.correct_answer
      assert_equal ['answer.save'], events.map(&:first)
    end
    events.each do |event|
      payload = event.last
      assert_equal @answer.id, payload[:answer].id
      assert_equal @question.id, payload[:answer].question_id
    end
    assert_equal "API::CorrectAnswersController##{action}", events.first.last[:action]
  end
end
