$(function() {
  var cf, cl, rl;
  $(":checked").parents("label").addClass("is-checked");
  $("input").click(function(e) {
    var chk, name, t;
    t = e.target.type;
    chk = $(this).prop("checked");
    name = $(this).attr("name");
    if (t === "checkbox") {
      if (chk === true) {
        $(this).parents("label").addClass("is-checked");
      } else {
        $(this).parents("label").removeClass("is-checked");
      }
      return true;
    } else if (t === "radio") {
      if (chk === true) {
        $(this).parents('ul').each(function() {
          return $(this).find('label').removeClass("is-checked");
        });
        $('input[name=" + name + "]').parents("ul label").removeClass("is-checked");
        $(this).parents('label').addClass("is-checked");
      }
      return true;
    }
  });
  $(this).find(":checked").closest("label").addClass("is-checked");
  cf = $(':radio').parent();
  cf.addClass('is-clickable');
  cf.click(function() {
    return $(this).find(':radio').attr('is-checked', true);
  });
  rl = $(':radio').parents("label");
  cl = $(':checkbox').parents("label");
  rl.addClass('radio-label');
  return cl.addClass('checkbox-label');
});
