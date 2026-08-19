import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const mentorMemo = document.querySelector('.user-mentor-memo')
  if (mentorMemo) {
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
            const memoItem = document.createElement('article')
            memoItem.className = 'user-mentor-memo-item'

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

            const content = document.createElement('div')
            content.className = 'user-mentor-memo-item__content'
            content.textContent = memo.content

            memoItem.appendChild(header)
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
                content.textContent = ''
                const editInput = document.createElement('input')
                editInput.className = 'a-text-input'
                editInput.type = 'text'
                editInput.value = memo.content
                content.appendChild(editInput)

                actionItems.textContent = ''
                const saveButton = document.createElement('button')
                saveButton.className = 'a-button is-xs is-primary'
                saveButton.textContent = '保存'

                const cancelButton = document.createElement('button')
                cancelButton.className = 'a-button is-xs is-secondary'
                cancelButton.textContent = 'キャンセル'
                actionItems.appendChild(saveButton)
                actionItems.appendChild(cancelButton)

                saveButton.addEventListener('click', () => {
                  editMemo(memo.id, editInput.value)
                })

                cancelButton.addEventListener('click', () => {
                  location.reload()
                })
              })
            }

            memoItems.appendChild(memoItem)
          })
          memoList.classList.remove('is-hidden')
        }
      })
      .catch((error) => {
        console.warn(error)
      })

    addButton.addEventListener('click', () => {
      const content = newInput.value
      updateMemo(content, userId)
    })

    function updateMemo(memo, userId) {
      const params = {
        user: {
          content: memo,
          user_id: userId
        }
      }
      fetch(`/api/mentor_memos/`, {
        method: 'POST',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Content-Type': 'application/json; charset=utf-8',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          if (response.ok) {
            location.reload()
          } else {
            alert('処理に失敗しました。')
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }

    function editMemo(id, content) {
      const params = {
        user: {
          content
        }
      }
      fetch(`/api/mentor_memos/${id}`, {
        method: 'PATCH',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Content-Type': 'application/json; charset=utf-8',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          if (response.ok) {
            location.reload()
          } else {
            alert('処理に失敗しました。')
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }

    function deleteMemo(id) {
      fetch(`/api/mentor_memos/${id}`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          if (response.ok) {
            location.reload()
          } else {
            alert('処理に失敗しました。')
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
})
