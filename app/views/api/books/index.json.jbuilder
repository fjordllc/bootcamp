json.books @books, partial: "api/books/book", as: :book

json.currentUser do
  json.adminOrMentor current_user.admin_or_mentor?
end
