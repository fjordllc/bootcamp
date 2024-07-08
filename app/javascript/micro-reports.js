document.addEventListener('DOMContentLoaded', function() {
  const textarea = document.getElementById('js-micro-report-textarea');
  const microReports = document.getElementById('js-micro-reports');
  const form = document.getElementById('js-micro-report-form');
  const scrollTarget = document.getElementById('js-scroll');
  let prevHeight = 0;

  // Initially set padding to 0 and add transition
  microReports.style.paddingBottom = '0px';
  microReports.style.transition = 'padding-bottom 0.3s ease';

  const adjustPadding = () => {
    const height = form.scrollHeight;
    if (height !== prevHeight) {
      microReports.style.paddingBottom = height + 'px';
      prevHeight = height;
    }
  };

  // Call adjustPadding on page load to set initial padding
  adjustPadding();

  // Event listener for textarea input
  textarea.addEventListener('input', () => {
    adjustPadding();
    scrollToBottom(scrollTarget);  // Ensure view is scrolled to bottom after adjusting padding
  });

  // Scroll to the bottom of the scrollTarget div as soon as the page loads
  scrollToBottom(scrollTarget);

  // MutationObserver to watch for style changes and adjust scroll
  const styleObserver = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.attributeName === 'style') {
        scrollToBottom(scrollTarget);
      }
    });
  });

  styleObserver.observe(microReports, {
    attributes: true,
    attributeFilter: ['style']
  });

  function scrollToBottom(element) {
    element.scrollTo({
      top: element.scrollHeight,
      behavior: 'smooth'
    });
  }

  // Debounce function to limit the rate of execution of a function
  function debounce(func, wait) {
    let timeout;
    return function(...args) {
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(this, args), wait);
    };
  }
});
