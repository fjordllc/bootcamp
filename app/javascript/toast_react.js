import Swal from 'sweetalert2'

const isMentorsCommentToProducts = (currentUser, commentableType) => {
  return currentUser.roles.includes('mentor') && commentableType === 'Product'
}

export const toast = (title, status = 'success') => {
  console.log(title)
  Swal.fire({
    title: title,
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
    customClass: { popup: `is-${status}` }
  })
}

export const displayToast = (
  toastMessage,
  productCheckerId,
  checkId,
  currentUser,
  commentableType
) => {
  if (isMentorsCommentToProducts(currentUser, commentableType)) {
    if (productCheckerId || checkId) {
      toast(confirmOrCommentMessage(toastMessage))
    }
  } else {
    toast(confirmOrCommentMessage(toastMessage))
  }
}

export const confirmOrCommentMessage = (toastMessage) => {
  return toastMessage ?? 'コメントを投稿しました！'
}

export const toastMessage = (commentableType) => {
  if (commentableType === 'Product') {
    return getToastMessage('提出物')
  } else if (commentableType === 'Report') {
    return getToastMessage('日報')
  } else {
    return null
  }
}

export const getToastMessage = (type) => {
  return `${type}を確認済みにしました。`
}
