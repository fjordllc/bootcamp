import useSWRInfinite from 'swr/infinite'
import { createComment, deleteComment, updateComment } from './commentApi'
import toast from '../../toast'
import fetcher from '../../fetcher'

export const useComment = ({
  commentableType,
  commentableId
}) => {
  // 1度に読み込むコメント数
  const paginationAmount = 8
  const apiUrl = '/api/comments.json?'

  const getKey = (pageIndex) => {
    const search = new URLSearchParams({
      commentable_type: commentableType,
      commentable_id: commentableId,
      comment_limit: paginationAmount,
      comment_offset: pageIndex * paginationAmount
    })
    return apiUrl + search
  }

  // useSWRInfiniteの使い方 https://swr.vercel.app/docs/pagination#useswrinfinite
  const {
    data,
    error,
    isLoading,
    isValidating,
    mutate,
    size,
    setSize,
  } = useSWRInfinite(getKey, fetcher, {
    revalidateAll: true,
    parallel: true
  })

  const commentTotalAmount = data ? data[0]?.comment_total_count : 0
  const loadedCommentAmount = commentTotalAmount > size * paginationAmount ? size * paginationAmount : commentTotalAmount
  const remainingCommentCount = commentTotalAmount - loadedCommentAmount
  const isShowLoadMore = remainingCommentCount > 0
  const loadMoreText = remainingCommentCount > 8
  ? `前のコメント（ ${loadedCommentAmount} / ${remainingCommentCount} ）`
  : `前のコメント（ ${remainingCommentCount} ）`


  // コメントのページネーションを１つ進める
  const handleLoadMore = () => setSize(size + 1)

  // 1. コメントの投稿
  // 2. swrのcacheの更新とrevalidation
  // 3. コメントに紐付けられた投稿をwatchする
  // 4. 提出物で担当者がおらず確認が済んでいない場合
  //   5.
  const handleCreateComment = async (description) => {
    const comment = await createComment(description, commentableType, commentableId)
    // https://github.com/vercel/swr/issues/908
    mutate(data, false)
    mutate()
    return comment
  }

  const handleUpdateComment = (id, description) => {
    updateComment(id, description)
      .then(() => {
        mutate(data, false)
        mutate()
        toast.methods.toast('コメントを更新しました！')
      })
      .catch((error) => {
        console.error(error)
        toast.methods.toast('コメントの更新に失敗しました', 'error')
      })
  }

  const handleDeleteComment = (commentId) => {
    deleteComment(commentId)
      .then(() => {
        mutate(data, false)
        mutate()
        toast.methods.toast('コメントを削除しました！')
      })
      .catch(() => {
        toast.methods.toast('コメントの削除に失敗しました', 'error')
      })
  }

  return {
    data,
    error,
    isLoading,
    isValidating,
    isShowLoadMore,
    loadMoreText,
    getKey,
    handleLoadMore,
    handleCreateComment,
    handleUpdateComment,
    handleDeleteComment,
  }
}
