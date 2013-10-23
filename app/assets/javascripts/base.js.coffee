$ ->
  if signed_in
    setInterval ->
      $.ajax
        type: "PUT"
        url: "/current_user"
    , 1000 * 60 * 2
