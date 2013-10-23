$ ->
  if signed_in
    setInterval ->
      console.log "access"
      $.ajax
        type: "POST"
        url: "/current_user"
        data: "_method=PUT"
    , 1000 * 60 * 2
