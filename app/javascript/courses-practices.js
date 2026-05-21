function setupCoursesPractices() {
  function scrollToCategory() {
    const count = location.href.search('#')
    const hash = location.href.slice(count + 1)
    const element = document.getElementById(hash)
    if (element) {
      element.scrollIntoView()
    }
  }
  scrollToCategory()
}

document.addEventListener('turbo:load', setupCoursesPractices)
document.addEventListener('DOMContentLoaded', setupCoursesPractices)
setupCoursesPractices()
