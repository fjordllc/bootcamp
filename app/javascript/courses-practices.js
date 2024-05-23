document.addEventListener('DOMContentLoaded', () => {
  function scrollToCategory() {
    const count = location.href.search('#')
    const hash = location.href.slice(count + 1)
    const element = document.getElementById(hash)
    if (element) {
      element.scrollIntoView()
    }
  }
  scrollToCategory()
})
