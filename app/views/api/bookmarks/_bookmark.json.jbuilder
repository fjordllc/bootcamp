bookmarkable = bookmark.bookmarkable
bookmarkable_title = bookmark.bookmarkable_type == 'Talk' ? "#{bookmarkable.user.long_name} さんの相談部屋" : bookmarkable.title
json.id bookmark.id
json.bookmarkable_id bookmark.bookmarkable_id
json.modelName bookmark.bookmarkable_type
json.modelNameI18n t("activerecord.models.#{bookmarkable.class.to_s.tableize.singularize}")
json.authorLoginName bookmarkable.user.login_name
json.authorNameKana bookmarkable.user.name_kana
json.authorUrl bookmarkable.user.url
json.user bookmarkable.user, partial: "api/users/user", as: :user
json.url polymorphic_url(bookmarkable)
json.title bookmarkable_title
json.created_at matched_document(bookmark.bookmarkable).created_at
json.updated_at matched_document(bookmark.bookmarkable).updated_at
json.reported_on matched_document(bookmark.bookmarkable).reported_on if bookmark.bookmarkable_type == "Report"
json.bookmark_class_name bookmark.bookmarkable_type.to_s.tableize.chop
json.summary searchable_summary(filtered_message(bookmark.bookmarkable)) unless bookmark.bookmarkable_type == 'Talk'
