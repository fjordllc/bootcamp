import Swal from 'sweetalert2'

export default {
  computed: {
    isMentorsCommentToProducts() {
      return (
        this.currentUser.roles.includes('mentor') &&
        this.commentableType === 'Product'
      )
    }
  },
  methods: {
    toast(title, status = 'success') {
      Swal.fire({
        title: title,
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        customClass: { popup: `is-${status}` }
      })
    },
    displayToast(toastMessage) {
      if (this.isMentorsCommentToProducts) {
        if (this.productCheckerId) {
          this.toast(this.confirmOrCommentMessage(toastMessage))
        }
      } else {
        this.toast(this.confirmOrCommentMessage(toastMessage))
      }
    },
    confirmOrCommentMessage(toastMessage) {
      return toastMessage ?? 'コメントを投稿しました！'
    },
    toastMessage() {
      if (this.commentableType === 'Product') {
        return this.getToastMessage('提出物')
      } else if (this.commentableType === 'Report') {
        return this.getToastMessage('日報')
      } else {
        return null
      }
    },
    getToastMessage(type) {
      return `${type}を確認済みにしました。`
    }
  }
}
