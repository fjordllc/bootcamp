document.addEventListener('DOMContentLoaded', () => {
  const notificationPage = document.querySelector('#notifications')
  if (!notificationPage) return

  const allOpenButton = document.querySelector(
    '#js-shortcut-unconfirmed-links-open'
  )
  if (!allOpenButton) return

  allOpenButton.addEventListener('click', () => {
    document.querySelector('.card-list')?.remove()
    allOpenButton.closest('.card-footer')?.remove()
    document.querySelector('.a-border-tint')?.remove()

    const container = document.querySelector('.page-content')
    if (container) {
      container.innerHTML = `
        <div class="o-empty-message">
          <div class="o-empty-message__icon">
            <div class="i fa-regular fa-smile"></div>
          </div>
          <p class="o-empty-message__text">未読の通知はありません</p>
        </div>
      `
    }
  })
})
