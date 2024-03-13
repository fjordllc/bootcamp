import { useCallback } from 'react'

/**
 * HTMLの仕様ではpreventDefaultによって確認ダイアログを出力させて、Chromeに対応するために必要な古い仕様ではreturnValueに空文字を設定する
 * @see https://html.spec.whatwg.org/multipage/nav-history-apis.html#the-beforeunloadevent-interface
 */
const handleBeforeUnload = (event) => {
  event.preventDefault()
  event.returnValue = ''
}

/**
 * 編集中の未保存のテキストがある状態でページ遷移しようとした時に警告の確認ダイアログを表示させるreact hookです
 * @see https://developer.chrome.com/docs/web-platform/page-lifecycle-api?hl=ja#the_beforeunload_event
 */
export const useBeforeunload = () => {
  /**
   * @returns {() => void} テキストの編集を始めたときに実行する関数
   */
  const onPageHasUnsavedChanges = useCallback(() => {
    addEventListener('beforeunload', handleBeforeUnload)
  }, [])

  /**
   * @returns {() => void} テキストの保存が完了したときに実行する関数
   */
  const onAllChangesSaved = useCallback(() => {
    removeEventListener('beforeunload', handleBeforeUnload)
  }, [])

  return { onPageHasUnsavedChanges, onAllChangesSaved }
}
