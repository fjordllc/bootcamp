// React18にアップデートしたらshimを使うのを辞めてください
import { useSyncExternalStore } from 'use-sync-external-store/shim'

// Proxyを使ってhistoryのメソッド呼び出しに合わせてイベントを発行する処理を挟みます
// https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Proxy
// Navigation APIには対応していません
// https://developer.mozilla.org/en-US/docs/Web/API/Navigation_API
function proxyHistoryMethod(method) {
  const handler = {
    // applyの関数は関数呼び出し時に実行されます
    // https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Proxy/Proxy/apply
    apply: function (target, thisArg, argumentsList) {
      const event = new Event(method.toLowerCase())
      window.dispatchEvent(event)
      return Reflect.apply(target, thisArg, argumentsList)
    }
  }

  history[method] = new Proxy(history[method], handler)
}

// historyのメソッドをproxyに置き換える
proxyHistoryMethod('pushState')
proxyHistoryMethod('replaceState')

function subscribe(callback) {
  window.addEventListener('pushstate', callback)
  window.addEventListener('replacestate', callback)
  window.addEventListener('popstate', callback)
  return () => {
    window.removeEventListener('pushstate', callback)
    window.removeEventListener('replacestate', callback)
    window.removeEventListener('popstate', callback)
  }
}

/**
 * URLが変わる度に再レンダリングを起こして新しいlocationを返すhookです
 * レンダリングされる瞬間にlocationを使う(locationの内容が表示に関係している)
 * 場合に使って下さい
 * @param {(location) => any} [selector=null] - locationの一部分だけ使いたい場合は関数を渡すことも出来ます
 * @example
 * location.pathnameのみ欲しい場合の例
 * const pathname = useLocation((location) => location.pathname)
 *
 * @see 参考 https://ja.react.dev/learn/lifecycle-of-reactive-effects#can-global-or-mutable-values-be-dependencies
 */
function useLocation(selector = (location) => location) {
  return useSyncExternalStore(subscribe, () => selector(location))
}

export { useLocation }
