json.hasAnyFootprints footprints.present?
if footprints.present?
  json.numberOfFootprints footprints.size
  json.footprints do
    json.array! footprints.footprinted_users do |user|
      json.user_icon user.avatar_url
      json.user_id user.id
    end
  end
end