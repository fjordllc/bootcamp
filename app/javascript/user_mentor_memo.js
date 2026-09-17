import { post, patch, destroy } from '@rails/request.js'
import MarkdownInitializer from 'markdown-initializer'

document.addEventListener('DOMContentLoaded', () => {
  const mentorMemo = document.querySelector('.user-mentor-memo')
  if (mentorMemo) {
    const markdownInitializer = new MarkdownInitializer()
    const userId = mentorMemo.dataset.user_id
    const currentUserId = mentorMemo.dataset.current_user_id
    let mentorMemos = []

    const status = mentorMemo.querySelector('.user-mentor-memo__status')
    const placeholder = mentorMemo.querySelector('.a-placeholder')
    const emptyMessage = mentorMemo.querySelector('.o-empty-message')
    const memoCount = mentorMemo.querySelector('.user-mentor-memo__count')
    const memoList = mentorMemo.querySelector('.user-mentor-memo__list')
    const memoItems = mentorMemo.querySelector('.user-mentor-memo__items')
    const newInput = mentorMemo.querySelector('.user-mentor-memo__new-input')
    const addButton = mentorMemo.querySelector('.user-mentor-memo__add-button')

    fetch(`/api/users/${userId}.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        mentorMemos = json.mentor_memos
        memoCount.textContent = `（${mentorMemos.length}）`
        placeholder.classList.add('is-hidden')
        if (mentorMemos.length === 0) {
          emptyMessage.classList.remove('is-hidden')
        } else {
          status.classList.add('is-hidden')
          mentorMemos.forEach((memo) => {
            memoItems.appendChild(buildMemoItem(memo))
          })
          memoList.classList.remove('is-hidden')
        }
      })
      .catch((error) => {
        console.warn(error)
      })

    addButton.addEventListener('click', () => {
      const content = newInput.value
      addButton.disabled = true
      updateMemo(content, userId)
    })

    function buildHeader(memo) {
      const header = document.createElement('header')
      header.className = 'user-mentor-memo-item__header'
      const avatar = document.createElement('img')
      avatar.className = 'a-user-icon user-mentor-memo-item__avatar'
      avatar.src = memo.author_avatar_url
      avatar.alt = `${memo.author}のアバター`
      const meta = document.createElement('div')
      meta.className = 'user-mentor-memo-item__meta'
      const author = document.createElement('h3')
      author.className = 'user-mentor-memo-item__author'
      author.textContent = memo.author
      const createdAt = document.createElement('time')
      createdAt.className = 'user-mentor-memo-item__created-at'
      createdAt.textContent = memo.created_at
      meta.appendChild(author)
      meta.appendChild(createdAt)
      header.appendChild(avatar)
      header.appendChild(meta)
      return header
    }

    function buildMemoItem(memo) {
      const memoItem = document.createElement('article')
      memoItem.className = 'user-mentor-memo-item'
      memoItem.appendChild(buildHeader(memo))

      const content = document.createElement('div')
      content.className = 'user-mentor-memo-item__content a-long-text is-sm'
      content.innerHTML = markdownInitializer.render(memo.content)
      memoItem.appendChild(content)

      if (String(memo.author_id) === currentUserId) {
        const actionItems = document.createElement('div')
        actionItems.className = 'user-mentor-memo-item__actions'
        const editButton = document.createElement('button')
        editButton.className = 'a-button is-xs is-secondary'
        editButton.textContent = '編集'

        const deleteButton = document.createElement('button')
        deleteButton.className = 'user-mentor-memo-item__delete-button'
        deleteButton.textContent = '削除する'

        actionItems.appendChild(editButton)
        actionItems.appendChild(deleteButton)
        memoItem.appendChild(actionItems)

        deleteButton.addEventListener('click', () => {
          if (confirm('本当に削除しますか？')) {
            deleteMemo(memo.id)
          }
        })

        editButton.addEventListener('click', () => {
          memoItem.replaceWith(buildEditItem(memo))
        })
      }

      return memoItem
    }

    function buildEditItem(memo) {
      const memoItem = document.createElement('article')
      memoItem.className = 'user-mentor-memo-item'
      memoItem.appendChild(buildHeader(memo))

      const tabs = document.createElement('div')
      tabs.className = 'a-form-tabs'
      const editTab = document.createElement('div')
      editTab.className = 'a-form-tabs__tab is-active'
      editTab.textContent = 'メモ'
      const previewTab = document.createElement('div')
      previewTab.className = 'a-form-tabs__tab'
      previewTab.textContent = 'プレビュー'
      tabs.appendChild(editTab)
      tabs.appendChild(previewTab)

      const markdownInput = document.createElement('div')
      markdownInput.className = 'a-markdown-input'

      const editorInner = document.createElement('div')
      editorInner.className = 'a-markdown-input__inner is-active'
      const editInput = document.createElement('textarea')
      editInput.className = 'a-text-input a-markdown-input__textarea'
      editInput.value = memo.content
      editorInner.appendChild(editInput)

      const previewInner = document.createElement('div')
      previewInner.className = 'a-markdown-input__inner'
      const preview = document.createElement('div')
      preview.className = 'a-long-text is-sm a-markdown-input__preview'
      previewInner.appendChild(preview)

      markdownInput.appendChild(editorInner)
      markdownInput.appendChild(previewInner)

      memoItem.appendChild(tabs)
      memoItem.appendChild(markdownInput)

      editTab.addEventListener('click', () => {
        editTab.classList.add('is-active')
        previewTab.classList.remove('is-active')
        editorInner.classList.add('is-active')
        previewInner.classList.remove('is-active')
      })
      previewTab.addEventListener('click', () => {
        preview.innerHTML = markdownInitializer.render(editInput.value)
        previewTab.classList.add('is-active')
        editTab.classList.remove('is-active')
        previewInner.classList.add('is-active')
        editorInner.classList.remove('is-active')
      })

      const actionItems = document.createElement('div')
      actionItems.className = 'user-mentor-memo-item__actions'
      const saveButton = document.createElement('button')
      saveButton.className = 'a-button is-xs is-primary'
      saveButton.textContent = '保存'

      const cancelButton = document.createElement('button')
      cancelButton.className = 'a-button is-xs is-secondary'
      cancelButton.textContent = 'キャンセル'
      actionItems.appendChild(saveButton)
      actionItems.appendChild(cancelButton)
      memoItem.appendChild(actionItems)

      saveButton.addEventListener('click', () => {
        editMemo(memo.id, editInput.value)
      })

      cancelButton.addEventListener('click', () => {
        memoItem.replaceWith(buildMemoItem(memo))
      })

      return memoItem
    }

    async function updateMemo(memo, userId) {
      const params = {
        user: {
          content: memo,
          user_id: userId
        }
      }

      const response = await post('/api/mentor_memos/', {
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        redirect: 'manual',
        body: params
      })

      if (response.ok) {
        location.reload()
      } else {
        alert('処理に失敗しました。')
        addButton.disabled = false
      }
    }

    async function editMemo(id, content) {
      const params = {
        user: {
          id,
          content
        }
      }
      const response = await patch(`/api/mentor_memos/${id}`, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        redirect: 'manual',
        body: params
      })

      if (response.ok) {
        location.reload()
      } else {
        alert('処理に失敗しました。')
      }
    }

    async function deleteMemo(id) {
      const params = {
        user: {
          id
        }
      }
      const response = await destroy(`/api/mentor_memos/${id}`, {
        method: 'DELETE',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        redirect: 'manual',
        body: params
      })
      if (response.ok) {
        location.reload()
      } else {
        alert('処理に失敗しました。')
      }
    }
  }
})
