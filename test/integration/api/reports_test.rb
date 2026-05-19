# frozen_string_literal: true

require 'test_helper'

class API::ReportsTest < ActionDispatch::IntegrationTest
  test 'GET /api/reports.json' do
    get api_reports_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_reports_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/reports/unchecked.json (only mentors)' do
    get api_reports_unchecked_index_path(format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_reports_unchecked_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/reports.json?user_id=984742968' do
    user = users(:with_hyphen)
    get api_reports_path(user_id: user.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_reports_path(user_id: user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/reports.json?company_id=1022975240' do
    company = companies(:company4)
    get api_reports_path(company_id: company.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_reports_path(company_id: company.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/reports.json' do
    token = create_token('kimura', 'testtest')

    assert_difference('Report.count') do
      post api_reports_path(format: :json),
           headers: { 'Authorization' => "Bearer #{token}" },
           params: { report: report_params }
      assert_response :created
    end

    report = Report.find(response.parsed_body['id'])
    assert_equal users(:kimura), report.user
    assert_equal 'APIで作成した日報', report.title
    assert_equal Date.new(2026, 5, 1), report.reported_on
    assert_equal 'positive', report.emotion
    assert_equal [practices(:practice1).id], report.practice_ids
    assert report.wip?
    assert_equal Time.zone.local(2026, 5, 1, 9, 0), report.learning_times.first.started_at
    assert_equal Time.zone.local(2026, 5, 1, 10, 0), report.learning_times.first.finished_at
  end

  test 'PATCH /api/reports/:id.json' do
    report = reports(:report1)
    token = create_token('komagata', 'testtest')

    patch api_report_path(report, format: :json),
          headers: { 'Authorization' => "Bearer #{token}" },
          params: {
            report: {
              title: 'APIで更新した日報',
              description: 'APIで本文を更新しました。',
              emotion: 'neutral',
              wip: false,
              practice_ids: [practices(:practice2).id],
              learning_times_attributes: {
                '0' => {
                  id: report.learning_times.first.id,
                  started_at: '08:00',
                  finished_at: '09:30'
                }
              }
            }
          }

    assert_response :ok
    report.reload
    assert_equal 'APIで更新した日報', report.title
    assert_equal 'APIで本文を更新しました。', report.description
    assert_equal 'neutral', report.emotion
    assert_equal [practices(:practice2).id], report.practice_ids
    assert_equal Time.zone.local(2017, 1, 1, 8, 0), report.learning_times.first.started_at
    assert_equal Time.zone.local(2017, 1, 1, 9, 30), report.learning_times.first.finished_at
  end

  test 'DELETE /api/reports/:id.json' do
    report = reports(:report1)
    token = create_token('komagata', 'testtest')

    assert_difference('Report.count', -1) do
      delete api_report_path(report, format: :json),
             headers: { 'Authorization' => "Bearer #{token}" }
      assert_response :ok
    end
  end

  test 'returns not found when updating other user report' do
    token = create_token('kimura', 'testtest')

    patch api_report_path(reports(:report1), format: :json),
          headers: { 'Authorization' => "Bearer #{token}" },
          params: { report: { title: '更新できない日報' } }

    assert_response :not_found
    assert_equal '日報が見つかりません。', response.parsed_body['message']
  end

  test 'returns validation error when creating invalid report' do
    token = create_token('kimura', 'testtest')

    assert_no_difference('Report.count') do
      post api_reports_path(format: :json),
           headers: { 'Authorization' => "Bearer #{token}" },
           params: { report: report_params.merge(title: '') }
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.dig('errors', 'title'), 'を入力してください'
  end

  private

  def report_params
    {
      title: 'APIで作成した日報',
      reported_on: '2026-05-01',
      emotion: 'positive',
      description: 'APIから日報を作成しました。',
      wip: true,
      practice_ids: [practices(:practice1).id],
      learning_times_attributes: {
        '0' => {
          started_at: '09:00',
          finished_at: '10:00'
        }
      }
    }
  end
end
