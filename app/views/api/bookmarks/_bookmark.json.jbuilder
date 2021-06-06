bookmarkable = bookmark.bookmarkable
model = bookmark.bookmarkable_type
json.id bookmark.id
json.model_name model
json.model_name_i18n t("activerecord.models.#{bookmarkable.class.to_s.tableize.singularize}")
json.user_name bookmarkable.user.name
json.url polymorphic_url(bookmarkable)
json.title bookmarkable.title
json.description bookmarkable.description
