import { patch } from '@rails/request.js'

document.addEventListener('DOMContentLoaded', () => {
  const tagChangeButton = document.querySelector('.change-tag-name-button')
  if (!tagChangeButton) return

  const tagEditModal = document.querySelector('.edit-tag-modal')
  const tagForm = tagEditModal.querySelector('.a-text-input')
  const cancelButton = tagEditModal.querySelector('.cancel-change-tag-button')
  const tagSaveButton = tagEditModal.querySelector('.save-tag-button')

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

  const updateTag = async (tagName) => {
    await patch(`/api/tags/${tagId}`, {
      body: JSON.stringify({ tag: { name: tagName } }),
      contentType: 'application/json'
    })
      .then(() => {
        updateTagList(tagName)
      })
      .catch((error) => {
        console.warn(error)
      })
  }
})
