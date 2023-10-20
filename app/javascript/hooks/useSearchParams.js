import { useRef, useEffect, useCallback, useMemo } from 'react'

function createSearchParams(init = '') {
  return new URLSearchParams(
    typeof init === 'string' ||
    Array.isArray(init) ||
    init instanceof URLSearchParams
      ? init
      : Object.keys(init).reduce((memo, key) => {
          const value = init[key]
          return memo.concat(
            Array.isArray(value) ? value.map((v) => [key, v]) : [[key, value]]
          )
        }, [])
  )
}

function getSearchParamsForLocation(locationSearch, defaultSearchParams) {
  const searchParams = createSearchParams(locationSearch)

  if (defaultSearchParams) {
    defaultSearchParams.forEach((_, key) => {
      if (!searchParams.has(key)) {
        defaultSearchParams.getAll(key).forEach((value) => {
          searchParams.append(key, value)
        })
      }
    })
  }

  return searchParams
}

/**
 * React RouterのuseSearchParamsと同じように働くので参考にしてください
 * @see https://reactrouter.com/en/main/hooks/use-search-params
 */
function useSearchParams(defaultInit) {
  const defaultSearchParamsRef = useRef(createSearchParams(defaultInit))
  const hasSetSearchParamsRef = useRef(false)

  const searchParams = useMemo(
    () =>
      getSearchParamsForLocation(
        location.search,
        hasSetSearchParamsRef.current ? null : defaultSearchParamsRef.current
      ),
    [location.search]
  )

  const defaultOptions = {
    replace: false,
    state: null,
    preventScrollReset: false
  }

  const setSearchParams = useCallback(
    (nextInit, { replace, state, preventScrollReset } = defaultOptions) => {
      const newSearchParams = createSearchParams(
        typeof nextInit === 'function' ? nextInit(searchParams) : nextInit
      )
      hasSetSearchParamsRef.current = true
      if (replace) {
        history.replaceState(state, '', '?' + newSearchParams)
      } else {
        history.pushState(state, '', '?' + newSearchParams)
      }
      if (!preventScrollReset) {
        window.scrollTo(0, 0)
      }
    },
    [searchParams]
  )

  return [searchParams, setSearchParams]
}

/**
 * @see https://usehooks-ts.com/react-hook/use-event-listener
 */
function usePopstate(handler) {
  const savedHandler = useRef(handler)

  useEffect(() => {
    savedHandler.current = handler
  }, [handler])

  useEffect(() => {
    if (!(window && window.addEventListener)) return
    const listener = (event) => savedHandler.current(event)
    window.addEventListener('popstate', listener)
    return () => {
      window.removeEventListener('popstate', listener)
    }
  }, [])
}

export { useSearchParams, usePopstate }
