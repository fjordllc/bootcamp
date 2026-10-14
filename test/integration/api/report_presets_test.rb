# frozen_string_literal: true

require 'test_helper'

class API::ReportPresetsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:kimura)
    token = create_token(@user.login_name, 'testtest')
    @headers = { 'Authorization' => "Bearer #{token}" }
  end

  test 'create report template' do
    assert_difference 'ReportPreset.count', 1 do
      post api_report_presets_path,
           params: { report_preset: { description: 'create test' } },
           headers: @headers,
           as: :json
    end

    assert_response :ok

    preset = ReportPreset.find(response.parsed_body['id'])

    assert_equal @user.id, preset.user_id
    assert_equal 'create test', preset.description
  end

  test 'cannot create another report template for the same user' do
    existing_preset = ReportPreset.create!(
      user: @user,
      description: 'existing template'
    )
    original_attributes = existing_preset.attributes

    assert_no_difference 'ReportPreset.count' do
      post api_report_presets_path,
           params: { report_preset: { description: 'another template' } },
           headers: @headers,
           as: :json
    end

    assert_response :bad_request
    assert_equal original_attributes, existing_preset.reload.attributes
  end

  test 'update report template' do
    preset = ReportPreset.create!(
      user: @user,
      description: 'existing template'
    )

    assert_no_difference 'ReportPreset.count' do
      put api_report_preset_path(preset),
          params: { report_preset: { description: 'updated template' } },
          headers: @headers,
          as: :json
    end

    assert_response :ok
    assert_equal 'updated template', preset.reload.description
  end
end
