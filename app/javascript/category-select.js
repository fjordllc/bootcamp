import 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  const categorySelect = document.querySelector(
    "select[name='practice[category_id]']"
  )
  const courseSelect = document.querySelector("select[name='course']")
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
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        categorySelect.innerHTML = ''
        for (let i = 0; i < json.length; i++) {
          const category = json[i]
          const option = document.createElement('option')
          option.value = category.id
          option.innerHTML = category.name
          categorySelect.appendChild(option)
        }

        const selectedCategoryId = document.querySelector(
          '#selected_category_id'
        ).value
        if (selectedCategoryId !== '') {
          document.querySelector("select[name='practice[category_id]']").value =
            selectedCategoryId
        }
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  courseSelect.addEventListener('change', changeCategory)
  changeCategory()
})
