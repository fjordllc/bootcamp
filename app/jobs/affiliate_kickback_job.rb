# frozen_string_literal: true

require 'net/http'

class AffiliateKickbackJob < ApplicationJob
  MOSHIMO_RESULT_URL = 'https://r.moshimo.com/af/r/result'
  PROMOTION_ID = 7462
  PC_ID = 21_548

  def perform(user_id, rd_code)
    uri = URI(MOSHIMO_RESULT_URL)
    uri.query = URI.encode_www_form(
      p_id: PROMOTION_ID,
      pc_id: PC_ID,
      m_v: user_id,
      rd_code: rd_code
    )
    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[Affiliate] Kickback failed for user #{user_id}: HTTP #{response.code} #{response.message}")
    end
  rescue StandardError => e
    Rails.logger.error("[Affiliate] Failed to send kickback for user #{user_id}: #{e.message}")
  end
end
