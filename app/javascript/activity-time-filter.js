document.addEventListener('DOMContentLoaded', function () {
  const dropdownButtons = document.querySelectorAll('.dropdown-button')
  const dropdownMenus = document.querySelectorAll('.dropdown-menu')

  // プルダウンメニューの開閉
  dropdownButtons.forEach((button) => {
    button.addEventListener('click', function (e) {
      e.preventDefault()
      const targetMenu = document.getElementById(
        this.getAttribute('data-target')
      )

      dropdownMenus.forEach((menu) => {
        if (menu !== targetMenu) menu.classList.remove('is-open')
      })

      targetMenu.classList.toggle('is-open')
    })
  })

  // プルダウンアイテムの選択
  document.querySelectorAll('.dropdown-item').forEach((item) => {
    item.addEventListener('click', function () {
      const dropdown = this.closest('.dropdown-wrapper')
      const button = dropdown.querySelector('.dropdown-button__text')
      const hiddenField = dropdown.querySelector('input[type="hidden"]')
      const menu = dropdown.querySelector('.dropdown-menu')

      button.textContent = this.textContent.trim()
      hiddenField.value = this.getAttribute('data-value')
      menu.classList.remove('is-open')
    })
  })

  // 外部クリックで閉じる
  document.addEventListener('click', function (e) {
    if (!e.target.closest('.dropdown-wrapper')) {
      dropdownMenus.forEach((menu) => menu.classList.remove('is-open'))
    }
  })
})
