import CSRF from './csrf'

document.addEventListener('DOMContentLoaded', () => {
  const tagForm = document.getElementById('tag_name')
  const tagChangeButton = document.querySelector('.change-tag-name-button')
  const tagEditModal = document.querySelector('.edit-tag-modal')
  const cancelButton = document.querySelector('.cancel-change-tag-button')
  const tagSaveButton = document.querySelector('.save-tag-button')

  const initialTagName = tagForm.dataset.initialTagName
  const tagId = tagForm.dataset.tagId

  const setShowModal = (isShow) => {
    tagEditModal.classList.toggle('hidden', !isShow)
  }

  tagChangeButton?.addEventListener('click', (e) => {
    e.preventDefault()
    setShowModal(true)
  })

  cancelButton?.addEventListener('click', (e) => {
    e.preventDefault()
    tagForm.value = initialTagName
    setShowModal(false)
  })

  tagSaveButton?.addEventListener('click', async (e) => {
    e.preventDefault()
    const tagName = tagForm.value
    updateTag(tagName)
  })

  tagForm?.addEventListener('keyup', (e) => {
    const tagValue = e.target.value
    if (tagValue === initialTagName || tagValue === '') {
      tagSaveButton.setAttribute('disabled', true)
    } else {
      tagSaveButton.removeAttribute('disabled')
    }
  })

  const updateTagList = (tagName) => {
    // 変更した内容を反映するためにリクエストを送り直している。
    // 変更内容を反映したい箇所がslimで書かれているため。
    location.href = location.pathname.replace(
      `/tags/${encodeURIComponent(initialTagName)}`,
      `/tags/${encodeURIComponent(tagName)}`
    )
  }

  const updateTag = (tagName) => {
    fetch(`/api/tags/${tagId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify({ tag: { name: tagName } })
    })
      .then(() => {
        updateTagList(tagName)
      })
      .catch((error) => {
        console.warn(error)
      })
  }
})
