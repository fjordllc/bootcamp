bookmarkable = bookmark.bookmarkable
json.id bookmark.id
json.modelName bookmark.bookmarkable_type
json.modelNameI18n t("activerecord.models.#{bookmarkable.class.to_s.tableize.singularize}")
json.author bookmarkable.user.name
json.authorUrl bookmarkable.user.url
json.url polymorphic_url(bookmarkable)
json.title bookmarkable.title
json.created_at matched_document(bookmark.bookmarkable).created_at
json.updated_at matched_document(bookmark.bookmarkable).updated_at
json.reported_on matched_document(bookmark.bookmarkable).reported_on if bookmark.bookmarkable_type == "Report"
json.bookmark_class_name bookmark.bookmarkable_type.to_s.tableize.chop
json.summary searchable_summary(filtered_message(bookmark.bookmarkable), 90)
