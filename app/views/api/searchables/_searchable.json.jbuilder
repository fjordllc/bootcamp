document = matched_document(searchable)
json.title document.title
json.url searchable_url(searchable)
json.model_name document.class.to_s.tableize.singularize
json.is_comment_or_answer comment_or_answer?(searchable)
json.model_name_with_i18n t("activerecord.models.#{document.class.to_s.tableize.singularize}")
json.summary searchable_summary(filtered_message(searchable), 90, params[:word])
json.updated_at searchable.updated_at
if searchable.respond_to?(:user)
  json.login_name searchable.user.login_name
  json.user_id searchable.user.id
end
if comment_or_answer?(searchable)
  json.document_author_login_name document.user.login_name
  json.document_author_id document.user.id
end
