/*============================================================
レビュープレビュースケール
============================================================*/

/*============================================================
レビュープレビュースケール
============================================================*/

function scaleReviewPreviews() {
	document.querySelectorAll('.reviewPreview').forEach(function(preview) {
		var content = preview.querySelector('.reviewPreviewContent');
		if (content) {
			var scale = preview.offsetWidth / 676;
			content.style.transform = 'scale(' + scale + ')';
		}
	});
}
window.addEventListener('resize', scaleReviewPreviews);

/*============================================================
スライド
============================================================*/

if (!$('.reviewsList').hasClass('slick-initialized')) {
	$('.reviewsList').on('init', scaleReviewPreviews).slick({
		dots: true,
		arrows: true,
		infinite: false,
		slidesToShow: 3,
		slidesToScroll: 1,
		appendDots: $('.custom-dots'),
		prevArrow: '<button class="prev-arrow">前へ</button>',
		nextArrow: '<button class="next-arrow">次へ</button>',
		appendArrows: $('.custom-arrows'),
		responsive: [{
			breakpoint: 767,
			settings: {
				slidesToShow: 1.5,
				slidesToScroll: 1,
			}
		}]
	});
}

$('.appSlider').slick({
	dots: false,
	arrows: true,
	infinite: false,
	slidesToShow: 1,
	slidesToScroll: 1,
	responsive: [{
		breakpoint: 767,
		settings: {
			slidesToShow: 1,
			slidesToScroll: 1,
		}
	}]
});

/*============================================================
モーダル
============================================================*/

$(function(){
	$('.modal').click(function() {
		$(this).fadeOut('fast');
	})
});
$(function(){
	$('.mo').click(function() {
		$(this).fadeOut('fast');
	})
});

$(function(){
	$('.modalBtn').click(function() {
		var tg = $(this).attr('tg');
		$('#' + tg).fadeIn('fast');
	})
});

/*============================================================
アコーディオン（メンター）
============================================================*/

$(function(){
	$('.accordion_head').click(function() {
		if($(this).is(".selected")){
			$(this).removeClass("selected");
		}else {
			$(this).addClass("selected");
		}
		var tg = $(this).attr('tg');
		$('#' + tg).fadeToggle(100);
		//$(this).prev().slideToggle();
	})
});

/*============================================================
アコーディオン（QA）
============================================================*/

$(function(){
	$('.qaQ').click(function() {
		if($(this).is(".selected")){
			$(this).removeClass("selected");
		}else {
			$(this).addClass("selected");
		}
		$(this).next().slideToggle('fast');
	})
});

/*============================================================
スムーズスクロール
============================================================*/

const header = document.querySelector("#header");
const headerHeight = header ? header.offsetHeight + 20 : 0;
function scrollToPos(position){
	const startPos = window.scrollY;
	const distance = Math.min(
		position - startPos,
		document.documentElement.scrollHeight - window.innerHeight - startPos
	);
	const duration = 800;
	let startTime;
	function easeOutExpo(t, b, c, d){
		return (c * (-Math.pow(2, (-10 * t) / d) + 1) * 1024) / 1023 + b;
	}
	function animation(currentTime){
		if (startTime === undefined){
			startTime = currentTime;
		}
		const timeElapsed = currentTime - startTime;
		const scrollPos = easeOutExpo(timeElapsed, startPos, distance, duration);
		window.scrollTo(0, scrollPos);
		if (timeElapsed < duration){
			requestAnimationFrame(animation);
		} else {
			window.scrollTo(0, position);
		
		}
	}
	requestAnimationFrame(animation);
}
function loadImages(){
	const targets = document.querySelectorAll("[data-src]");
	for (const target of targets) {
		const dataSrc = target.getAttribute("data-src");
		const currentSrc = target.getAttribute("src");
		if (dataSrc !== currentSrc) {
			target.setAttribute("src",dataSrc);
		}
	}
}
for (const link of document.querySelectorAll('a[href*="#"]')){
	link.addEventListener("click", (e) => {
		const hash = e.currentTarget.hash;
		const target = document.getElementById(hash.slice(1));
		if (!hash || hash === "#top"){
			e.preventDefault();
			scrollToPos(0);
		} else if (target) {
			e.preventDefault();
			loadImages();
			const position =
			target.getBoundingClientRect().top + window.scrollY - headerHeight;
			scrollToPos(position);
			history.pushState(null, "", hash);
		}
	});
}
const urlHash = window.location.hash;
if (urlHash) {
	const target = document.getElementById(urlHash.slice(1));
	if (target){
		history.replaceState(null, "", window.location.pathname);
		window.scrollTo(0, 0);
		loadImages();
		window.addEventListener("load", () => {
			const position = target.getBoundingClientRect().top + window.scrollY - headerHeight;
			scrollToPos(position);
			history.replaceState(null, "", window.location.pathname + urlHash);
		});
	}
}