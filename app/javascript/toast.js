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
    }
  }
}
