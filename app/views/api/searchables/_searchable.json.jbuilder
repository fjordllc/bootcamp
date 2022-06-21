document = matched_document(searchable)
json.title document.title
json.url searchable_url(searchable)
json.model_name document.class.to_s.tableize.singularize
json.model_name_with_i18n t("activerecord.models.#{document.class.to_s.tableize.singularize}")
json.summary searchable_summary(filtered_message(searchable), 90, params[:word])
json.updated_at searchable.updated_at
json.wip searchable.respond_to?(:wip?) ? searchable.wip? : false
if searchable.respond_to?(:user)
  json.login_name searchable.user.login_name
  json.user_id searchable.user.id
end
json.is_comment_or_answer comment_or_answer?(searchable)
if comment_or_answer?(searchable)
  json.document_author_login_name document.user.login_name
  json.document_author_id document.user.id
end
if talk?(searchable)
  json.talk_id searchable.talk.id
end
json.is_user user?(searchable)
if user?(searchable)
  json.avatar_url searchable.avatar_url
  json.primary_role searchable.primary_role
end
