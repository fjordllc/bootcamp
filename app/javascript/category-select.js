import 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  const categorySelect = document.querySelector('select#practice_category_id')
  const courseSelect = document.querySelector('select#course_id')
  if (!categorySelect || !courseSelect) {
    return null
  }

  const changeCategory = () => {
    const courseId = courseSelect.value
    fetch(`/api/categories.json?course_id=${courseId}`, {
      method: 'GET',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      credentials: 'same-origin'
    })
      .then(response => {
        return response.json()
      })
      .then(json => {
        categorySelect.innerHTML = ''
        for (let i = 0; i < json.length; i++) {
          const category = json[i]
          const option = document.createElement('option')
          option.value = category.id
          option.innerHTML = category.name
          categorySelect.appendChild(option)
        }
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
  }

  courseSelect.addEventListener('change', changeCategory)
  changeCategory()
})
