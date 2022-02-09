import Swal from 'sweetalert2'

export default class {
  static initialize(parent, selector) {
    const meta = document.querySelector('meta[name="csrf-token"]')
    const token = meta ? meta.content : ''

    const markdowns = document.querySelectorAll(parent || '.js-markdown-view')

    markdowns.forEach((md) => {
      const taskable = md.getAttribute('data-taskable') === 'true'
      const taskableId = Number(md.getAttribute('data-taskable-id'))
      const taskableType = md.getAttribute('data-taskable-type')

      if (taskable && taskableId && taskableType) {
        const checkboxes = md.querySelectorAll(
          selector || '.task-list-item-checkbox'
        )

        checkboxes.forEach((checkbox, i) => {
          checkbox.disabled = false
          checkbox.addEventListener('change', () => {
            this.toggleCheckbox(
              taskableId,
              taskableType,
              i,
              checkbox.checked,
              token
            )
          })
        })
      }
    })
  }

  static toggleCheckbox(id, type, ntn, checked, token) {
    fetch(
      `/api/markdown_tasks.json?taskable_type=${type}&taskable_id=${id}&checked=${checked}&nth=${ntn}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token
        },
        credentials: 'same-origin',
        redirect: 'manual'
      }
    )
      .then((response) => {
        return response.json()
      })
      .then((_json) => {
        Swal.fire({
          title: 'チェックボックスを変更しました！',
          toast: true,
          position: 'top-end',
          showConfirmButton: false,
          timer: 3000,
          timerProgressBar: true
        })
      })
      .catch((error) => {
        console.warn(error)
      })
  }
}
