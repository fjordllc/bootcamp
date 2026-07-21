import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const mentorMemo = document.querySelector('.user-mentor-memo')
  if (mentorMemo) {
    const userId = mentorMemo.dataset.user_id
    const currentUserId = mentorMemo.dataset.current_user_id
    let mentorMemos = []

    const memoDisplay = mentorMemo.querySelector('.memo-display')

    const placeholder = memoDisplay.querySelector('.a-placeholder')
    const emptyMessage = memoDisplay.querySelector('.o-empty-message')
    const memoList = mentorMemo.querySelector('.user-mentor-memo-list')
    const memoItems = mentorMemo.querySelector('.user-mentor-memo-items')
    const newInput = mentorMemo.querySelector('.user-mentor-memo-new-input')
    const addButton = mentorMemo.querySelector('.user-mentor-memo-add-button')

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
        placeholder.classList.add('is-hidden')
        if (mentorMemos.length === 0) {
          emptyMessage.classList.remove('is-hidden')
        } else {
          mentorMemos.forEach((memo) => {
            const tr = document.createElement('tr')
            const contentCell = document.createElement('td')
            const nameCell = document.createElement('td')
            const updatedCell = document.createElement('td')
            const updatedButtonCell = document.createElement('td')
            if (String(memo.author_id) === currentUserId) {
              const editButton = document.createElement('button')
              editButton.textContent = '編集'
              updatedButtonCell.appendChild(editButton)

              const deleteButton = document.createElement('button')
              deleteButton.textContent = '削除'
              updatedButtonCell.appendChild(deleteButton)

              deleteButton.addEventListener('click', () => {
                if (confirm('本当に削除しますか？')) {
                  deleteMemo(memo.id)
                }
              })

              editButton.addEventListener('click', () => {
                contentCell.textContent = ''
                const editInput = document.createElement('input')
                editInput.type = 'text'
                editInput.value = memo.content
                contentCell.appendChild(editInput)

                updatedButtonCell.textContent = ''
                const saveButton = document.createElement('button')
                saveButton.textContent = '保存'
                updatedButtonCell.appendChild(saveButton)

                const cancelButton = document.createElement('button')
                cancelButton.textContent = 'キャンセル'
                updatedButtonCell.appendChild(cancelButton)

                saveButton.addEventListener('click', () => {
                  editMemo(memo.id, editInput.value)
                })

                cancelButton.addEventListener('click', () => {
                  location.reload()
                })
              })
            }

            contentCell.textContent = memo.content
            tr.appendChild(contentCell)
            nameCell.textContent = memo.author
            tr.appendChild(nameCell)
            updatedCell.textContent = memo.created_at
            tr.appendChild(updatedCell)
            tr.appendChild(updatedButtonCell)

            memoItems.appendChild(tr)
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
          location.reload()
        })
        .catch((error) => {
          console.warn(error)
        })
    }

    function editMemo(id, content) {
      const params = {
        user: {
          content: content
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
          location.reload()
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
          location.reload()
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
})
