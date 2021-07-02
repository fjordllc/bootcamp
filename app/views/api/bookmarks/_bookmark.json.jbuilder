bookmarkable = bookmark.bookmarkable
json.id bookmark.id
json.modelName bookmark.bookmarkable_type
json.modelNameI18n t("activerecord.models.#{bookmarkable.class.to_s.tableize.singularize}")
json.author bookmarkable.user.name
json.authorUrl bookmarkable.user.url
json.url polymorphic_url(bookmarkable)
json.title bookmarkable.title
json.createdAt l(bookmarkable.created_at)
json.updatedAt l(bookmarkable.updated_at)
json.reportedOn l(bookmarkable.reported_on) if bookmark.bookmarkable_type == "Report"
json.bookmark_class_name bookmark.bookmarkable_type.to_s.tableize.chop
json.summary searchable_summary(filtered_message(bookmark.bookmarkable), 90)
