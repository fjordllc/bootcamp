$(function() {
	$('.js-tabs__tab').click(function() {
    var trigger = $('.js-tabs__tab');
    var target = $('.js-tabs__content');
		var index = $('.js-tabs__tab').index(this);
		target.removeClass('is-active');
		target.eq(index).addClass('is-active');
		trigger.removeClass('is-active');
		$(this).addClass('is-active')
	});
});
