import CSRF from 'csrf'

function changeButtonAppearance(userId) {
  const details = event.target.closest('#followingDetailsRef')
  const followingSummary = details.children[0]
  const dropdownItems = details.querySelector('.a-dropdown__items')
  const firstDropdownItem = dropdownItems.children[0]
  const secondDropdownItem = dropdownItems.children[1]
  const thirdDropdownItem = dropdownItems.children[2]
  details.removeAttribute('open')

  if (
    event.currentTarget.children[0].children[0].textContent === 'コメントあり'
  ) {
    while (followingSummary.firstChild) {
      followingSummary.removeChild(followingSummary.firstChild)
    }
    const button = document.createElement('span')
    button.classList.add('a-button', 'is-warning', 'is-sm', 'is-block')
    const checkMark = document.createElement('i')
    checkMark.classList.add('fa-solid', 'fa-check')
    const text = document.createElement('span')
    text.textContent = 'コメントあり'
    button.appendChild(checkMark)
    button.appendChild(text)
    followingSummary.appendChild(button)
    firstDropdownItem.children[0].classList.add('is-active')
    firstDropdownItem.children[0].setAttribute(
      'onclick',
      'userFollow.closeDropDown()'
    )
    secondDropdownItem.children[0].setAttribute(
      'onclick',
      `userFollow.followOrChangeFollow(${userId}, ${true}, ${false} )`
    )
    thirdDropdownItem.children[0].setAttribute(
      'onclick',
      `userFollow.unfollow(${userId},${true}, ${true})`
    )
    if (secondDropdownItem.children[0].classList.contains('is-active')) {
      secondDropdownItem.children[0].classList.remove('is-active')
    } else if (thirdDropdownItem.children[0].classList.contains('is-active')) {
      thirdDropdownItem.children[0].classList.remove('is-active')
    }
  } else if (
    event.currentTarget.children[0].children[0].textContent === 'コメントなし'
  ) {
    while (followingSummary.firstChild) {
      followingSummary.removeChild(followingSummary.firstChild)
    }
    const button = document.createElement('span')
    button.classList.add('a-button', 'is-warning', 'is-sm', 'is-block')
    const checkMark = document.createElement('i')
    checkMark.classList.add('fa-solid', 'fa-check')
    const text = document.createElement('span')
    text.textContent = 'コメントなし'
    button.appendChild(checkMark)
    button.appendChild(text)
    followingSummary.appendChild(button)
    secondDropdownItem.children[0].classList.add('is-active')
    secondDropdownItem.children[0].setAttribute(
      'onclick',
      'userFollow.closeDropDown()'
    )
    firstDropdownItem.children[0].setAttribute(
      'onclick',
      `userFollow.followOrChangeFollow(${userId}, ${true}, ${true} )`
    )
    thirdDropdownItem.children[0].setAttribute(
      'onclick',
      `userFollow.unfollow(${userId}, ${true}, ${false})`
    )
    if (firstDropdownItem.children[0].classList.contains('is-active')) {
      firstDropdownItem.children[0].classList.remove('is-active')
    } else if (thirdDropdownItem.children[0].classList.contains('is-active')) {
      thirdDropdownItem.children[0].classList.remove('is-active')
    }
  } else if (
    event.currentTarget.children[0].children[0].textContent === 'フォローしない'
  ) {
    details.children[0].children[0].textContent = 'フォローする'
    details.children[0].children[0].className =
      'a-button is-secondary is-sm is-block'
    thirdDropdownItem.children[0].classList.add('is-active')
    thirdDropdownItem.children[0].setAttribute(
      'onclick',
      'userFollow.closeDropDown()'
    )
    firstDropdownItem.children[0].setAttribute(
      'onclick',
      `userFollow.followOrChangeFollow(${userId}, ${false}, ${true} )`
    )
    secondDropdownItem.children[0].setAttribute(
      'onclick',
      `userFollow.followOrChangeFollow(${userId}, ${false}, ${false} )`
    )
    if (firstDropdownItem.children[0].classList.contains('is-active')) {
      firstDropdownItem.children[0].classList.remove('is-active')
    } else if (secondDropdownItem.children[0].classList.contains('is-active')) {
      secondDropdownItem.children[0].classList.remove('is-active')
    }
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
