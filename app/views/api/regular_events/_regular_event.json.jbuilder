json.(regular_event, :id, :title, :wip, :start_at, :end_at, :finished)
json.title regular_event.title
json.start_at_localized l regular_event.start_at, format: :time_only
json.end_at_localized l regular_event.end_at, format: :time_only
json.finished regular_event.finished
json.category t("activerecord.enums.regular_event.category.#{regular_event.category}")
json.category_class regular_event.category
json.comments_count regular_event.comments.size
json.url regular_event_url(regular_event)
json.organizers regular_event.organizers, partial: "api/users/user", as: :user
json.holding_cycles regular_event.holding_cycles
