import { useStore } from 'zustand'
// Zustandをreact抜きで使う（vueで使う)ためにvanillaからimportしています https://github.com/pmndrs/zustand#using-zustand-without-react
// vuexが無くなったらvanillaを使わずに直接React hookを作るようにする
import { createStore } from 'zustand/vanilla'

// React無しでの使い方 https://github.com/pmndrs/zustand#readingwriting-state-and-reacting-to-changes-outside-of-components
const zustandStore = createStore((set) => ({
  // 日報と提出物の確認状態の確認スタンプと確認ボタン、確認OKコメントボタンに使用
  checkable: {
    checkId: null,
    userName: null,
    createdAt: null,
    checkableId: null,
    checkableType: null
  },
  // watch-toggleコンポーネントで使用
  watchId: null,
  // 日報と提出物の確認状態の共有に使用
  setCheckable: ({ checkableId, checkableType }) => {
    fetch(
      `/api/checks.json/?checkable_type=${checkableType}&checkable_id=${checkableId}`,
      {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin'
      }
    )
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        console.log(json)
        set(() => ({
          checkable: {
            checkId: json[0]?.id ?? null,
            createdAt: json[0]?.created_at ?? null,
            userName: json[0]?.user?.login_name ?? null,
            checkableId: checkableId,
            checkableType: checkableType
          }
        }))
      })
      .catch((error) => {
        console.warn(error)
      })
  },
  // commentとwatch-toggleが同ページ内で共存しているページでの状態共有に使用
  setWatchable: ({ watchableId, watchableType }) => {
    fetch(
      `/api/watches/toggle.json?watchable_id=${watchableId}&watchable_type=${watchableType}`,
      {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin'
      }
    )
      .then((response) => {
        return response.json()
      })
      .then((watchable) => {
        set(() => ({ watchId: watchable[0]?.id ?? null }))
      })
      .catch((error) => {
        console.warn(error)
      })
  }
}))

// Reactで使うためのReact hook
const useZustandStore = (selector) => useStore(zustandStore, selector)

export { zustandStore, useZustandStore }
