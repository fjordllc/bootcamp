import CSRF from 'csrf'

function replaceSummary(details, text) {
  const followingSummary = details.children[0]
  while (followingSummary.firstChild) {
    followingSummary.removeChild(followingSummary.firstChild)
  }
  const button = document.createElement('span')
  button.classList.add('a-button', 'is-warning', 'is-sm', 'is-block')
  const checkMark = document.createElement('i')
  checkMark.classList.add('fa-solid', 'fa-check')
  const summaryContent = document.createElement('span')
  summaryContent.textContent = text
  button.appendChild(checkMark)
  button.appendChild(summaryContent)
  followingSummary.appendChild(button)
}

function inactivateButtons(notSelectedButtons) {
  if (notSelectedButtons[0].classList.contains('is-active')) {
    notSelectedButtons[0].classList.remove('is-active')
  } else if (notSelectedButtons[1].classList.contains('is-active')) {
    notSelectedButtons[1].classList.remove('is-active')
  }
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
    firstDropdownItemButton.classList.add('is-active')
    firstDropdownItemButton.setAttribute(
      'onclick',
      'userFollow.closeDropDown()'
    )
    secondDropdownItemButton.setAttribute('id', 'without-comments')
    secondDropdownItemButton.setAttribute(
      'onclick',
      `userFollow.followOrChangeFollow(${userId}, ${true}, ${false} )`
    )
    thirdDropdownItemButton.setAttribute('id', 'unfollow')
    thirdDropdownItemButton.setAttribute(
      'onclick',
      `userFollow.unfollow(${userId},${true}, ${true})`
    )
    const notSelectedButtons = [
      secondDropdownItemButton,
      thirdDropdownItemButton
    ]
    inactivateButtons(notSelectedButtons)
  } else if (event.currentTarget.id === 'without-comments') {
    replaceSummary(details, 'コメントなし')
    secondDropdownItemButton.classList.add('is-active')
    secondDropdownItemButton.setAttribute(
      'onclick',
      'userFollow.closeDropDown()'
    )
    firstDropdownItemButton.setAttribute('id', 'with-comments')
    firstDropdownItemButton.setAttribute(
      'onclick',
      `userFollow.followOrChangeFollow(${userId}, ${true}, ${true} )`
    )
    thirdDropdownItemButton.setAttribute('id', 'unfollow')
    thirdDropdownItemButton.setAttribute(
      'onclick',
      `userFollow.unfollow(${userId}, ${true}, ${false})`
    )
    const notSelectedButtons = [
      firstDropdownItemButton,
      thirdDropdownItemButton
    ]
    inactivateButtons(notSelectedButtons)
  } else if (event.currentTarget.id === 'unfollow') {
    details.children[0].children[0].textContent = 'フォローする'
    details.children[0].children[0].className =
      'a-button is-secondary is-sm is-block'
    thirdDropdownItemButton.classList.add('is-active')
    thirdDropdownItemButton.setAttribute(
      'onclick',
      'userFollow.closeDropDown()'
    )
    firstDropdownItemButton.setAttribute('id', 'with-comments')
    firstDropdownItemButton.setAttribute(
      'onclick',
      `userFollow.followOrChangeFollow(${userId}, ${false}, ${true} )`
    )
    secondDropdownItemButton.setAttribute('id', 'without-comments')
    secondDropdownItemButton.setAttribute(
      'onclick',
      `userFollow.followOrChangeFollow(${userId}, ${false}, ${false} )`
    )
    const notSelectedButtons = [
      firstDropdownItemButton,
      secondDropdownItemButton
    ]
    inactivateButtons(notSelectedButtons)
  }
}

const userFollow = {
  followOrChangeFollow(userId, isFollowing, isWatching) {
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
  },
  unfollow(userId, isFollowing, isWatching) {
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
  },
  closeDropDown() {
    const details = event.target.closest('#followingDetailsRef')
    details.removeAttribute('open')
  }
}

window.userFollow = userFollow
