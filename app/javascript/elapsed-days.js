export default function elapsedDays({
  countProductsGroupedBy,
  productDeadlineDay
}) {
  const activeClass = (quantity) => (quantity ? 'is-active' : 'is-inactive')

  const createNavigationItem = ({
    elapsedDays,
    additionalClass = '',
    todayProducts
  }) => {
    const li = createList(elapsedDays, additionalClass)
    const a = createAnchor(elapsedDays)
    const span = createSpan(elapsedDays, todayProducts)

    a.appendChild(span)
    li.appendChild(a)
    return li
  }

  const createList = (elapsedDays, additionalClass) => {
    const li = document.createElement('li')
    li.className = `page-nav__item ${additionalClass} ${activeClass(
      countProductsGroupedBy(elapsedDays)
    )}`.trim()
    return li
  }

  const createAnchor = (elapsedDays) => {
    const a = document.createElement('a')
    a.className = 'page-nav__item-link'
    a.href = `#${elapsedDays}days-elapsed`
    return a
  }

  const createSpan = (elapsedDays, todayProducts) => {
    const span = document.createElement('span')
    span.className = 'page-nav__item-link-inner'
    span.textContent =
      todayProducts ||
      `${elapsedDays}日${
        elapsedDays >= 6 ? '以上' : ''
      }経過 (${countProductsGroupedBy(elapsedDays)})`
    return span
  }

  const div = document.createElement('div')
  div.className = 'page-nav a-card'

  const ol = document.createElement('ol')
  ol.className = 'page-nav__items elapsed-days'

  ol.appendChild(
    createNavigationItem({
      elapsedDays: productDeadlineDay + 2,
      additionalClass: 'is-reply-deadline border-b-0'
    })
  )
  ol.appendChild(
    createNavigationItem({
      elapsedDays: productDeadlineDay + 1,
      additionalClass: 'is-reply-alert border-b-0'
    })
  )
  ol.appendChild(
    createNavigationItem({
      elapsedDays: productDeadlineDay,
      additionalClass: 'is-reply-warning border-b-0'
    })
  )

  Array.from({ length: productDeadlineDay - 1 }, (_, index) => index + 1)
    .reverse()
    .forEach((passedDay) =>
      ol.appendChild(
        createNavigationItem({
          elapsedDays: passedDay
        })
      )
    )

  ol.appendChild(
    createNavigationItem({
      elapsedDays: 0,
      todayProducts: `今日提出 (${countProductsGroupedBy(0)})`
    })
  )

  div.appendChild(ol)
  return div
}
