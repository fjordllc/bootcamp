import CSRF from 'csrf'

function followOrChangeFollow(userId, isFollowing, isWatching) {
  const url = isFollowing
    ? `/api/followings/${userId}?watch=${isWatching}`
    : `/api/followings?watch=${isWatching}`
  const verb = isFollowing ? 'PATCH' : 'POST'
  const params = {
    id: userId
  }
  fetch(url, {
    method: verb,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual',
    body: JSON.stringify(params)
  })
    .then((response) => {
      if (response.ok) {
        if (!isFollowing) {
          isFollowing = true
        }
      } else {
        alert('フォロー処理に失敗しました')
      }
    })
    .catch((error) => {
      console.warn(error)
    })
  changeButtonAppearance(userId)
}

function unfollow(userId, isFollowing, isWatching) {
  const url = isFollowing
    ? `/api/followings/${userId}?watch=${isWatching}`
    : `/api/followings?watch=${isWatching}`
  const params = {
    id: userId
  }
  fetch(url, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual',
    body: JSON.stringify(params)
  })
    .then((response) => {
      if (!response.ok) {
        alert('フォロー処理に失敗しました')
      }
    })
    .catch((error) => {
      console.warn(error)
    })
  changeButtonAppearance(userId)
}

function closeDropDown(event) {
  const details = event.target.closest('#followingDetailsRef')
  details.removeAttribute('open')
}

function changeButtonAppearance(userId) {
  const details = event.target.closest('#followingDetailsRef')
  const dropdownItems = details.querySelector('.a-dropdown__items')
  const firstDropdownItemButton = dropdownItems.children[0].children[0]
  const secondDropdownItemButton = dropdownItems.children[1].children[0]
  const thirdDropdownItemButton = dropdownItems.children[2].children[0]

  details.removeAttribute('open')

  if (event.currentTarget.id === 'with-comments') {
    replaceSummary(details, 'コメントあり')
    const notSelectedButtons = [
      secondDropdownItemButton,
      thirdDropdownItemButton
    ]
    updateButtonAttributes(firstDropdownItemButton, notSelectedButtons, [
      {
        id: 'without-comments',
        'data-action': 'followOrChangeFollow',
        'data-user-id': userId,
        'data-is-following': true,
        'data-is-watching': false
      },
      {
        id: 'unfollow',
        'data-action': `unfollow`,
        'data-user-id': userId,
        'data-is-following': true,
        'data-is-watching': true
      }
    ])
  } else if (event.currentTarget.id === 'without-comments') {
    replaceSummary(details, 'コメントなし')
    const notSelectedButtons = [
      firstDropdownItemButton,
      thirdDropdownItemButton
    ]
    updateButtonAttributes(secondDropdownItemButton, notSelectedButtons, [
      {
        id: 'with-comments',
        'data-action': 'followOrChangeFollow',
        'data-user-id': userId,
        'data-is-following': true,
        'data-is-watching': true
      },
      {
        id: 'unfollow',
        'data-action': `unfollow`,
        'data-user-id': userId,
        'data-is-following': true,
        'data-is-watching': false
      }
    ])
  } else if (event.currentTarget.id === 'unfollow') {
    replaceSummary(details, 'フォローする')
    const notSelectedButtons = [
      firstDropdownItemButton,
      secondDropdownItemButton
    ]
    updateButtonAttributes(thirdDropdownItemButton, notSelectedButtons, [
      {
        id: 'with-comments',
        'data-action': 'followOrChangeFollow',
        'data-user-id': userId,
        'data-is-following': false,
        'data-is-watching': true
      },
      {
        id: 'without-comments',
        'data-action': 'followOrChangeFollow',
        'data-user-id': userId,
        'data-is-following': false,
        'data-is-watching': false
      }
    ])
  }
}

function replaceSummary(details, text) {
  const followingSummary = details.children[0]
  while (followingSummary.firstChild) {
    followingSummary.removeChild(followingSummary.firstChild)
  }

  const button = document.createElement('span')

  if (text === 'フォローする') {
    button.className = 'a-button is-secondary is-sm is-block'
  } else {
    button.className = 'a-button is-warning is-sm is-block'
    const checkMark = document.createElement('i')
    checkMark.classList.add('fa-solid', 'fa-check')
    button.appendChild(checkMark)
  }

  const summaryContent = document.createElement('span')
  summaryContent.textContent = text
  button.appendChild(summaryContent)
  followingSummary.appendChild(button)
}

function updateButtonAttributes(
  selectedButton,
  notSelectedButtons,
  attributesSet
) {
  const keys = [
    'id',
    'data-action',
    'data-user-id',
    'data-is-following',
    'data-is-watching'
  ]
  for (let i = 0; i < notSelectedButtons.length; i++) {
    keys.forEach((key) => {
      notSelectedButtons[i].setAttribute(key, attributesSet[i][key])
    })
  }
  selectedButton.classList.add('is-active')
  selectedButton.setAttribute('data-action', 'closeDropDown')
  if (notSelectedButtons[0].classList.contains('is-active')) {
    notSelectedButtons[0].classList.remove('is-active')
  } else if (notSelectedButtons[1].classList.contains('is-active')) {
    notSelectedButtons[1].classList.remove('is-active')
  }
}

document.addEventListener('click', (event) => {
  if (!event.target.closest('#followingDetailsRef')) {
    const allDetails = document.querySelectorAll('#followingDetailsRef')
    for (let i = 0; i < allDetails.length; i++) {
      allDetails[i].removeAttribute('open')
    }
  }
})

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('button[data-action]').forEach((button) => {
    button.addEventListener('click', (event) => {
      const action = event.currentTarget.dataset.action
      const userId = event.currentTarget.dataset.userId
      const isFollowing = event.currentTarget.dataset.isFollowing === 'true'
      const isWatching = event.currentTarget.dataset.isWatching === 'true'
      if (action === 'followOrChangeFollow') {
        followOrChangeFollow(userId, isFollowing, isWatching)
      } else if (action === 'unfollow') {
        unfollow(userId, isFollowing, isWatching)
      } else if (action === 'closeDropDown') {
        closeDropDown(event)
      }
    })
  })
})
