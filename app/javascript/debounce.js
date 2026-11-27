export function debounce(func, wait) {
  let timeout
  function debounced(...args) {
    clearTimeout(timeout)
    timeout = setTimeout(() => func.apply(this, args), wait)
  }

  debounced.clear = () => {
    clearTimeout(timeout)
    timeout = undefined
  }

  return debounced
}
