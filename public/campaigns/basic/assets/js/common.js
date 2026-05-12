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

function equalizePortfolioHeights() {
	var items = document.querySelectorAll('.structurePortfolioList li .structurePortfolioListInner');
	items.forEach(function(item) {
		item.style.height = '';
	});
	if (!window.matchMedia('(min-width: 768px)').matches) {
		return;
	}
	var maxHeight = 0;
	items.forEach(function(item) {
		maxHeight = Math.max(maxHeight, item.offsetHeight);
	});
	items.forEach(function(item) {
		item.style.height = maxHeight + 'px';
	});
}

function buildSlider(selector, options) {
	document.querySelectorAll(selector).forEach(function(slider) {
		if (slider.classList.contains('slick-initialized')) {
			return;
		}
		slider.classList.add('slick-initialized');
		slider.style.display = 'flex';
		slider.style.flexWrap = 'nowrap';
		slider.style.overflowX = 'auto';
		slider.style.scrollSnapType = 'x mandatory';
		slider.querySelectorAll(':scope > *').forEach(function(slide) {
			slide.classList.add('slick-slide');
			slide.style.flex = '0 0 ' + options.slideWidth;
			slide.style.scrollSnapAlign = 'start';
		});

		var arrows = document.querySelector(options.appendArrows) || slider.parentElement;
		if (arrows) {
			var prev = document.createElement('button');
			var next = document.createElement('button');
			prev.className = options.prevClass;
			next.className = options.nextClass;
			prev.type = 'button';
			next.type = 'button';
			prev.textContent = '前へ';
			next.textContent = '次へ';
			arrows.append(prev, next);
			prev.addEventListener('click', function() {
				slider.scrollBy({ left: -slider.clientWidth, behavior: 'smooth' });
			});
			next.addEventListener('click', function() {
				slider.scrollBy({ left: slider.clientWidth, behavior: 'smooth' });
			});
		}

		var dots = document.querySelector(options.appendDots);
		if (dots) {
			var list = document.createElement('ul');
			var slides = slider.querySelectorAll(':scope > *');
			slides.forEach(function(slide, index) {
				var item = document.createElement('li');
				var button = document.createElement('button');
				button.type = 'button';
				button.textContent = String(index + 1);
				button.addEventListener('click', function() {
					slider.scrollTo({ left: slide.offsetLeft - slider.offsetLeft, behavior: 'smooth' });
				});
				item.append(button);
				list.append(item);
			});
			dots.append(list);
		}
	});
}

/*============================================================
スライド
============================================================*/

document.addEventListener('DOMContentLoaded', function() {
	buildSlider('.reviewsList', {
		appendArrows: '.custom-arrows',
		appendDots: '.custom-dots',
		prevClass: 'prev-arrow slick-arrow',
		nextClass: 'next-arrow slick-arrow',
		slideWidth: window.matchMedia('(max-width: 767px)').matches ? '66.666%' : '33.333%'
	});
	buildSlider('.appSlider', {
		appendArrows: '.appSliderArrows',
		prevClass: 'slick-prev slick-arrow',
		nextClass: 'slick-next slick-arrow',
		slideWidth: '100%'
	});
	scaleReviewPreviews();
	equalizePortfolioHeights();
});
window.addEventListener('load', equalizePortfolioHeights);
window.addEventListener('resize', equalizePortfolioHeights);

/*============================================================
モーダル
============================================================*/

document.querySelectorAll('.modal, .mo').forEach(function(element) {
	element.addEventListener('click', function() {
		element.style.display = 'none';
	});
});
document.querySelectorAll('.modalBtn').forEach(function(button) {
	button.addEventListener('click', function() {
		var target = document.getElementById(button.getAttribute('tg'));
		if (target) {
			target.style.display = 'block';
		}
	});
});

/*============================================================
アコーディオン（メンター）
============================================================*/

document.querySelectorAll('.accordion_head').forEach(function(head) {
	head.addEventListener('click', function() {
		head.classList.toggle('selected');
		var target = document.getElementById(head.getAttribute('tg'));
		if (target) {
			target.style.display = target.style.display === 'none' ? 'block' : 'none';
		}
	});
});

/*============================================================
アコーディオン（QA）
============================================================*/

document.querySelectorAll('.qaQ').forEach(function(question) {
	question.addEventListener('click', function() {
		question.classList.toggle('selected');
		var answer = question.nextElementSibling;
		if (answer) {
			answer.style.display = answer.style.display === 'none' ? 'block' : 'none';
		}
	});
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
