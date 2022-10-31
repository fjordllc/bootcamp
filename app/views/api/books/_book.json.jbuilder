json.id book.id
json.title book.title
json.price book.price
json.description book.description
json.pageUrl book.page_url
json.coverUrl book.cover_url
json.editBookPath edit_book_path(book)
json.mustRead must_read_for_any_practices?(book)

json.practices book.practices, partial: "api/books/practice", as: :practice
