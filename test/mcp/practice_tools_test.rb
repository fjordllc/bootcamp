# frozen_string_literal: true

require 'test_helper'

class McpPracticeToolsTest < ActiveSupport::TestCase
  CANONICAL_ORIGIN = 'https://bootcamp.example'

  test 'tool schemas declare the expected names, bounded inputs, and read-only annotations' do
    assert_equal 'list_practices', Mcp::ListPractices.tool_name
    assert_equal 'get_practice', Mcp::GetPractice.tool_name
    assert Mcp::ListPractices.annotations_value.read_only_hint
    assert Mcp::GetPractice.annotations_value.read_only_hint
    assert_equal ['practice_id'], Mcp::GetPractice.input_schema_value.to_h[:required]
    assert_equal 100, Mcp::ListPractices.input_schema_value.to_h.dig(:properties, :limit, :maximum)
    assert_equal %w[id title summary description goal updated_at url], Mcp::GetPractice.output_schema_value.to_h[:required]
    assert_not_includes Mcp::GetPractice.output_schema_value.to_h[:required], 'memo'
    assert_equal %w[string null], Mcp::GetPractice.output_schema_value.to_h.dig(:properties, :memo, :type)
    assert_equal %w[string null], Mcp::ListPractices.output_schema_value.to_h.dig(:properties, :practices, :items, :properties, :summary, :type)
    assert Mcp::ListPractices.to_h[:outputSchema]
    assert Mcp::GetPractice.to_h[:outputSchema]
  end

  test 'list returns ascending IDs with a next cursor and continues after that cursor' do
    first_page = Mcp::ListPractices.call(limit: 3, server_context: server_context)
    first_result = first_page.structured_content

    Mcp::ListPractices.output_schema_value.validate_result(first_result)
    assert_equal Practice.order(:id).limit(3).pluck(:id), first_result.fetch('practices').pluck('id')
    assert_equal first_result.fetch('practices').last.fetch('id'), first_result.fetch('next_cursor')

    second_page = Mcp::ListPractices.call(cursor: first_result.fetch('next_cursor'), limit: 3, server_context: server_context)

    Mcp::ListPractices.output_schema_value.validate_result(second_page.structured_content)
    assert_equal Practice.where('id > ?', first_result.fetch('next_cursor')).order(:id).limit(3).pluck(:id),
                 second_page.structured_content.fetch('practices').pluck('id')

    default_page = Mcp::ListPractices.call(server_context: server_context).structured_content
    assert_equal 20, default_page.fetch('practices').length
    assert_not_nil default_page.fetch('next_cursor')

    final_page = Mcp::ListPractices.call(limit: 100, server_context: server_context).structured_content
    assert_equal Practice.order(:id).pluck(:id), final_page.fetch('practices').pluck('id')
    assert_nil final_page.fetch('next_cursor')
  end

  test 'list searches titles as literal substrings and preserves distinct same-title records' do
    literals = [practices(:practice1), practices(:practice2), practices(:practice3)]
    decoys = [practices(:practice4), practices(:practice5), practices(:practice6)]
    titles = [
      ['MCP literal 80% percent', 'MCP literal 800 percent', '80% percent'],
      ['MCP literal A_B underscore', 'MCP literal A-B underscore', 'A_B underscore'],
      ['MCP literal a\\b slash', 'MCP literal ab slash', 'a\\b slash']
    ]

    titles.each_with_index do |(literal_title, decoy_title, query), index|
      literals[index].update!(title: literal_title)
      decoys[index].update!(title: decoy_title)
      result = Mcp::ListPractices.call(query:, limit: 10, server_context: server_context).structured_content

      assert_equal [literals[index].id], result.fetch('practices').pluck('id'), query
    end
  end

  test 'list uses an empty query as no filter and rejects invalid argument types and bounds' do
    all_records = Mcp::ListPractices.call(query: '  ', limit: 100, server_context: server_context).structured_content
    assert_equal Practice.order(:id).limit(100).pluck(:id), all_records.fetch('practices').pluck('id')

    [
      { query: 12 },
      { query: 'x' * 201 },
      { cursor: '2' },
      { cursor: 0 },
      { cursor: 2_147_483_648 },
      { limit: '5' },
      { limit: 0 },
      { limit: 101 }
    ].each do |arguments|
      response = Mcp::ListPractices.call(**arguments, server_context: server_context)
      assert response.error?, arguments.inspect
      assert_nil response.structured_content
    end
  end

  test 'get serializes only the fixed practice fields and preserves Markdown and Japanese text' do
    practice = practices(:practice3)
    practice.update!(summary: '', description: "# 日本語の見出し\n\n本文 **Markdown**", goal: "- 目標\n- 完了条件", memo: nil)

    response = Mcp::GetPractice.call(practice_id: practice.id, server_context: server_context(users(:mentormentaro)))
    data = response.structured_content
    Mcp::GetPractice.output_schema_value.validate_result(data)

    assert_equal %w[description goal id memo summary title updated_at url].sort, data.keys.sort
    assert_equal "# 日本語の見出し\n\n本文 **Markdown**", data.fetch('description')
    assert_equal "- 目標\n- 完了条件", data.fetch('goal')
    assert_equal '', data.fetch('summary')
    assert_nil data.fetch('memo')
    assert_equal "#{CANONICAL_ORIGIN}/practices/#{practice.id}", data.fetch('url')
    assert_match(/"description": "# 日本語の見出し\\n\\n本文 \*\*Markdown\*\*"/, response.content.first.fetch(:text))
    assert_not_includes data.keys, 'submission'
    assert_not_includes response.content.first.fetch(:text), 'practice_quiz'
  end

  test 'memo is present only for mentor and admin across both structured and text results' do
    practice = practices(:practice1)
    allowed_users = [users(:mentormentaro), users(:adminonly)]
    allowed_users.each do |user|
      response = Mcp::GetPractice.call(practice_id: practice.id, server_context: server_context(user))
      Mcp::GetPractice.output_schema_value.validate_result(response.structured_content)
      assert_equal practice.memo, response.structured_content.fetch('memo')
      assert_includes response.content.first.fetch(:text), 'memo'
    end

    [users(:kimura), users(:kensyu), users(:advijirou)].each do |user|
      response = Mcp::GetPractice.call(practice_id: practice.id, server_context: server_context(user))
      Mcp::GetPractice.output_schema_value.validate_result(response.structured_content)
      assert_not response.structured_content.key?('memo')
      assert_not_includes response.content.first.fetch(:text), 'memo'
      assert_not_includes response.content.first.fetch(:text), practice.memo
    end
  end

  test 'nullable summary and memo fields remain null for an authorized reader' do
    practice = practices(:practice2)
    response = Mcp::GetPractice.call(practice_id: practice.id, server_context: server_context)
    data = response.structured_content

    Mcp::GetPractice.output_schema_value.validate_result(data)
    assert_nil data.fetch('summary')
    assert data.key?('memo')
    assert_nil data.fetch('memo')
  end

  test 'get can independently serialize a copied practice and returns only the requested record' do
    copy = practices(:practice64)
    source = copy.source_practice

    result = Mcp::GetPractice.call(practice_id: copy.id, server_context: server_context).structured_content

    assert_equal copy.id, result.fetch('id')
    assert_equal copy.title, result.fetch('title')
    assert_equal "#{CANONICAL_ORIGIN}/practices/#{copy.id}", result.fetch('url')
    assert_not_equal source.id, result.fetch('id')
    assert_equal copy.description, result.fetch('description')
  end

  test 'get reports missing and invalid IDs as tool errors' do
    [nil, '1', 0, -1, 2_147_483_648].each do |practice_id|
      response = Mcp::GetPractice.call(practice_id:, server_context: server_context)
      assert response.error?, practice_id.inspect
      assert_nil response.structured_content
    end

    response = Mcp::GetPractice.call(practice_id: Practice.maximum(:id) + 100, server_context: server_context)
    assert response.error?
    assert_includes response.content.first.fetch(:text), 'was not found'
  end

  test 'get fails with an explicit error rather than truncating an oversized practice body' do
    practice = practices(:practice1)
    practice.update!(description: 'oversized ' * Rails.configuration.x.mcp.max_tool_response_bytes)

    response = Mcp::GetPractice.call(practice_id: practice.id, server_context: server_context)

    assert response.error?
    assert_nil response.structured_content
    assert_includes response.content.first.fetch(:text), 'exceeds the configured'
    assert_not_includes response.content.first.fetch(:text), 'oversized'
  end

  test 'the largest fixture detail response fits the configured byte limit' do
    user = users(:mentormentaro)
    details = Practice.order(:id).map do |practice|
      Mcp::PracticeSerializer.detail(practice, user:, canonical_origin: CANONICAL_ORIGIN)
    end
    sizes = details.map { |data| response_payload_bytes(data) }
    largest = sizes.max

    assert_operator largest, :<, Rails.configuration.x.mcp.max_tool_response_bytes
  end

  private

  def server_context(user = users(:mentormentaro))
    { user:, canonical_origin: CANONICAL_ORIGIN }
  end

  def response_payload_bytes(data)
    text = JSON.pretty_generate(data)
    JSON.generate(content: [{ type: 'text', text: }], structuredContent: data).bytesize
  end
end
