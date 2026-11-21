# frozen_string_literal: true

# Staged observation only: violations appear in the browser console/events.
# Inline scripts (including the importmap bootstrap) and eval have not yet been
# migrated to nonces/hashes. This policy is not ready for enforcement, and no
# reporting endpoint or external collector is configured.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.object_src :none
    policy.base_uri :self
    policy.frame_ancestors :self
    policy.script_src :self,
                      'https://ga.jspm.io', 'https://esm.sh', 'https://cdn.jsdelivr.net',
                      'https://cdnjs.cloudflare.com', 'https://ajax.googleapis.com',
                      'https://js.stripe.com', 'https://platform.twitter.com',
                      'https://cdn.syndication.twimg.com', 'https://static.ads-twitter.com',
                      'https://www.googletagmanager.com', 'https://cdn.rollbar.com',
                      'https://sdk.form.run', 'https://connect.facebook.net', 'https://b.st-hatena.com'
    policy.style_src :self, :https, :unsafe_inline
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data, :blob
  end

  config.content_security_policy_report_only = true
end
