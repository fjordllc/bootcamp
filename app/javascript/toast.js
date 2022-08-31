import Swal from 'sweetalert2'

export default {
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

    toastMessage() {
      if (this.commentableType === 'Product') return this.getToastMessage('提出物')
      if (this.commentableType === 'Report') return this.getToastMessage('日報')
      return null
    },

    getToastMessage(type) {
      return `${type}を確認済みにしました。`
    }
  }
}
