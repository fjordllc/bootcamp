document.addEventListener('DOMContentLoaded', () => {
  masonry({
    target: '.js-masonry',
    column: 3,
    responsive: [
      {
        breakpoint: 1199,
        column: 2
      },
      {
        breakpoint: 767,
        column: 1
      }
    ]
  })
  function masonry(setOptions) {
    'use strict'
    const defaultOptions = {
      target: '.js-masonry',
      activeClass: 'is-active',
      listClass: '.js-masonry',
      listElmsClass: '.js-masonry__item'
    }
    const options = Object.assign({}, defaultOptions, setOptions)
    const listClass = options.listClass
    const listElmsClass = options.listElmsClass
    const lists = Array.prototype.slice.call(
      document.querySelectorAll(listClass),
      0
    )
    if (lists.length === 0) {
      return false
    }
    masonryFunk(options)
    window.addEventListener('resize', function () {
      masonryFunk(options)
    })
    function masonryFunk(options) {
      let column = options.column
      const responsive = options.responsive
      if (responsive) {
        const winWidth = window.innerWidth
        for (let i = 0; i < responsive.length; i++) {
          if (winWidth <= responsive[i].breakpoint) {
            column = responsive[i].column
          }
        }
      }
      if (column === 1) {
        lists.forEach(function (list) {
          const listElms = Array.prototype.slice.call(
            list.querySelectorAll(listElmsClass),
            0
          )
          listElms.forEach(function (listElm) {
            listElm.style.marginTop = ''
          })
        })
        return false
      }
      lists.forEach(function (list) {
        const listElms = Array.prototype.slice.call(
          list.querySelectorAll(listElmsClass),
          0
        )
        if (listElms.length === 0) {
          return false
        }
        if (!list.classList.contains(options.activeClass)) {
          list.classList.add(options.activeClass)
        }
        listElms.forEach(function (listElm, index) {
          listElm.style.marginTop = ''
          if (column > index) {
            return
          }
          const topListElm = listElms[index - column]
          const topListElmPosi = topListElm.getBoundingClientRect().top
          const topListHeight = getHeightAndMarginBottom(topListElm)
          const topListBottomPosi = topListElmPosi + topListHeight
          const listElmPosi = listElm.getBoundingClientRect().top
          let setPosi = listElmPosi.toFixed(0) - topListBottomPosi.toFixed(0)
          if (setPosi === 0) {
            return false
          }
          setPosi = '-' + setPosi + 'px'
          listElm.style.marginTop = setPosi
        })
      })
    }

    function getHeightAndMarginBottom(elm) {
      const height = elm.getBoundingClientRect().height
      const styles = getComputedStyle(elm)
      const bottom = parseFloat(styles.marginBottom)
      return height + bottom
    }
  }
})
