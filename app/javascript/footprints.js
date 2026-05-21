function setupFootprints() {
  const userIconsContainer = document.querySelector('.user-icons')
  const loadingMessage = document.querySelector('.user-icons__loading')

  if (userIconsContainer && loadingMessage) {
    loadingMessage.remove()

    const moreLink = document.querySelector('.user-icons__more')
    if (moreLink) {
      if (moreLink.dataset.footprintsInitialized === 'true') return

      moreLink.dataset.footprintsInitialized = 'true'
      moreLink.addEventListener('click', () => {
        const remainingFootprints = document.getElementById(
          'remaining-footprints'
        )
        const initialFootprintsContainer =
          document.getElementById('initial-footprints')

        while (remainingFootprints.firstChild) {
          initialFootprintsContainer.appendChild(remainingFootprints.firstChild)
        }

        moreLink.remove()
      })
    }
  }
}

document.addEventListener('turbo:load', setupFootprints)
document.addEventListener('DOMContentLoaded', setupFootprints)
setupFootprints()
