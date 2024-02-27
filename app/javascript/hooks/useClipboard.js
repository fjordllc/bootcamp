import { useState, useEffect } from 'react'

/**
 * copy クリップボードへのコピーを実行する関数です
 * @param {string} text クリップボードへコピーするテキスト
 * @return {boolean} コピーが成功したらtrue 失敗したらfalse
 */
const copy = (text) => {
  const textArea = document.createElement('textarea')
  try {
    textArea.setAttribute('type', 'hidden')
    textArea.textContent = text ?? ''
    document.body.appendChild(textArea)
    textArea.select()
    // 非推奨な機能
    // 将来的にはnavigator.clipboardを使ったほうが良いかも
    // https://developer.mozilla.org/ja/docs/Mozilla/Add-ons/WebExtensions/Interact_with_the_clipboard
    document.execCommand('copy')
    document.body.removeChild(textArea)
    return true
  } catch {
    return false
  }
}

/**
 * useClipboard クリップボードに指定したテキストをコピーするhookです
 * @param {string} text クリップボードへコピーするテキスト
 * @param {number} duration コピー成功後にisCopiedをリセットするまでの時間
 * @return {[boolean, () => void]} [isCopied, execCopy] [コピーの成否を表すboolean, コピーの実行をする関数]
 */
export const useClipboard = (text, duration) => {
  const [isCopied, setIsCopied] = useState(false)

  useEffect(() => {
    if (isCopied && duration) {
      /**
       * Reactの警告で [Violation] 'setTimeout' handler took [x]ms が出る可能性がある
       * setTimeoutを使わない方法があればそっちの方が良いかも
       */
      const id = setTimeout(() => {
        setIsCopied(false)
      }, duration)

      return () => {
        clearTimeout(id)
      }
    }
  }, [isCopied, duration])

  return [
    isCopied,
    () => {
      const didCopy = copy(text)
      setIsCopied(didCopy)
    }
  ]
}
