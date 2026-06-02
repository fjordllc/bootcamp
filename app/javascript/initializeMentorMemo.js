import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'

export default function initializeMemo(memo) {
  const markdownInitializer = new MarkdownInitializer()

  const memoId = memo.dataset.memo_id
  const memoBody = memo.dataset.memo_body
  TextareaInitializer.initialize(`#js-mentor-memo-${memoId}`)

  const memoDisplayContent = memo.querySelector('.memo-text')

  if (memoBody) {
    memoDisplayContent.innerHTML = markdownInitializer.render(memoBody)
  }
}
