# frozen_string_literal: true

module Performance
  class ReportGate
    def initialize(state: SharedState.new, verifier: Rails.application.message_verifier('performance-report-v1'))
      @state = state
      @verifier = verifier
    end

    def issue(session_binding:, page:, now: Time.current)
      return unless Pages::REGISTRY.key?(page)

      token = @state.synchronize(1) { issue_locked(session_binding, page, now.to_i) }
      token == :busy ? nil : token
    rescue SharedState::Unavailable
      nil
    end

    def accept(token:, session_binding:, page:, now: Time.current)
      claims = @verifier.verified(token, purpose: 'initial-document')
      return :invalid unless valid_claims?(claims, session_binding, page, now.to_i)

      @state.synchronize(1) { consume(claims, now.to_i) }
    rescue SharedState::Unavailable
      :unavailable
    end

    private

    def issue_locked(binding, page, now)
      budget = @state.read('budget') || { 'generation' => SecureRandom.hex(16), 'accepted' => [] }
      record = @state.read("session:#{binding}")
      if !record || record['budget_generation'] != budget['generation']
        record = { 'generation' => SecureRandom.hex(16), 'budget_generation' => budget['generation'], 'nonces' => {}, 'accepted' => [] }
      end
      record['nonces'].delete_if { |_nonce, value| value['expires'] <= now }
      return limited(now) if record['nonces'].length >= 60

      nonce = SecureRandom.hex(16)
      record['nonces'][Digest::SHA256.hexdigest(nonce)] = { 'expires' => now + 3600, 'used' => false }
      @state.write('budget', budget)
      @state.write("session:#{binding}", record)
      @verifier.generate({ 'v' => 1, 'p' => page, 'b' => binding, 'g' => record['generation'], 'n' => nonce, 'i' => now, 'e' => now + 3600 },
                         purpose: 'initial-document')
    end

    def valid_claims?(claims, binding, page, now)
      claims.is_a?(Hash) && claims.keys.sort == %w[b e g i n p v] && claims['v'] == 1 &&
        claims['p'] == page && claims['b'] == binding && valid_ticket?(claims, now)
    end

    def valid_ticket?(claims, now)
      claims['n'].is_a?(String) && claims['g'].is_a?(String) && claims['i'].is_a?(Integer) && claims['e'].is_a?(Integer) &&
        claims['i'] <= now && claims['e'] > now && claims['e'] - claims['i'] == 3600
    end

    def consume(claims, now)
      key = "session:#{claims['b']}"
      record = @state.read(key)
      nonce = live_nonce(record, claims, now)
      return :invalid unless nonce
      return :duplicate if nonce['used']

      budget = @state.read('budget')
      return :unavailable unless budget

      return :invalid unless record['budget_generation'] == budget['generation']

      record['accepted'].reject! { |time| time <= now - 60 }
      budget['accepted'].reject! { |time| time <= now - 60 }
      return limited(now, :limited) if at_capacity?(record, budget)

      nonce['used'] = true
      record['accepted'] << now
      budget['accepted'] << now
      @state.write('budget', budget)
      @state.write(key, record)
      :accepted
    end

    def at_capacity?(record, budget)
      record['accepted'].length >= 6 || budget['accepted'].length >= 60
    end

    def live_nonce(record, claims, now)
      return unless record && record['generation'] == claims['g']

      nonce = record.dig('nonces', Digest::SHA256.hexdigest(claims['n']))
      nonce if nonce && nonce['expires'] > now
    end

    def limited(now, result = nil)
      range = @state.read('limited_at')
      range = { 'first' => now, 'last' => now } unless range && range['last'] >= now - 25.hours
      range['last'] = now
      @state.write('limited_at', range, expires_in: 25.hours)
      result
    end
  end
end
