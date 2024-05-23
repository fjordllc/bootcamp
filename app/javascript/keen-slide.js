import KeenSlider from 'keen-slider'

document.addEventListener('DOMContentLoaded', () => {
  console.log('aaa')
  const slider = new KeenSlider("#my-keen-slider", {
      loop: true,
      mode: "free-snap",
      breakpoints: {
        "(min-width: 400px)": {
          slides: { perView: 2, spacing: 5 },
        },
        "(min-width: 1000px)": {
          slides: { perView: 3, spacing: 10 },
        },
      },
      slides: {
        perView: 4,
        spacing: 15,
      },
    },
    [navigation])

  // スライダーが初期化された後のイベントリスナーを追加
  slider.on("slideChanged", (s) => {
    console.log(`Current slide index: ${s.track.details.rel}`)
  })

  function navigation(slider) {
    let wrapper, dots, arrowLeft, arrowRight

    function markup(remove) {
      wrapperMarkup(remove)
      dotMarkup(remove)
      arrowMarkup(remove)
    }

    function removeElement(elment) {
      elment.parentNode.removeChild(elment)
    }

    function createDiv(className) {
      var div = document.createElement("div")
      var classNames = className.split(" ")
      classNames.forEach((name) => div.classList.add(name))
      return div
    }

    function arrowMarkup(remove) {
      if (remove) {
        removeElement(arrowLeft)
        removeElement(arrowRight)
        return
      }
      arrowLeft = createDiv("arrow arrow--left")
      arrowLeft.addEventListener("click", () => slider.prev())
      arrowRight = createDiv("arrow arrow--right")
      arrowRight.addEventListener("click", () => slider.next())

      wrapper.appendChild(arrowLeft)
      wrapper.appendChild(arrowRight)
    }

    function wrapperMarkup(remove) {
      if (remove) {
        var parent = wrapper.parentNode
        while (wrapper.firstChild)
          parent.insertBefore(wrapper.firstChild, wrapper)
        removeElement(wrapper)
        return
      }
      wrapper = createDiv("navigation-wrapper")
      slider.container.parentNode.appendChild(wrapper)
      wrapper.appendChild(slider.container)
    }

    function dotMarkup(remove) {
      if (remove) {
        removeElement(dots)
        return
      }
      dots = createDiv("dots")
      slider.track.details.slides.forEach((_e, idx) => {
        var dot = createDiv("dot")
        dot.addEventListener("click", () => slider.moveToIdx(idx))
        dots.appendChild(dot)
      })
      wrapper.appendChild(dots)
    }

    function updateClasses() {
      var slide = slider.track.details.rel
      slide === 0 ?
        arrowLeft.classList.add("arrow--disabled") :
        arrowLeft.classList.remove("arrow--disabled")
      slide === slider.track.details.slides.length - 1 ?
        arrowRight.classList.add("arrow--disabled") :
        arrowRight.classList.remove("arrow--disabled")
      Array.from(dots.children).forEach(function (dot, idx) {
        idx === slide ?
          dot.classList.add("dot--active") :
          dot.classList.remove("dot--active")
      })
    }

    slider.on("created", () => {
      markup()
      updateClasses()
    })
    slider.on("optionsChanged", () => {
      console.log(2)
      markup(true)
      markup()
      updateClasses()
    })
    slider.on("slideChanged", () => {
      updateClasses()
    })
    slider.on("destroyed", () => {
      markup(true)
    })
  }
})
