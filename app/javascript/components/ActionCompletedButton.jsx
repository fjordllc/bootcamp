import React, { useState } from 'react'
import { patch } from '@rails/request.js'
import toast from '../toast'

export default function ActionCompletedButton({
  isInitialActionCompleted,
  commentableId,
  modelName = 'inquiry',
  apiPath = '/api/inquiries'
}) {
  const [isActionCompleted, setIsActionCompleted] = useState(
    isInitialActionCompleted
  )
  const [isLoading, setIsLoading] = useState(false)

  const handleClick = async () => {
    const previousState = isActionCompleted
    const newState = !isActionCompleted
    setIsActionCompleted(newState)
    setIsLoading(true)

    try {
      const params = {}
      params[modelName] = { action_completed: newState }

      const response = await patch(`${apiPath}/${commentableId}`, {
        body: JSON.stringify(params),
        contentType: 'application/json'
      })

      if (response.ok) {
        toast.methods.toast(`${newState ? '対応済み' : '未対応'}にしました`)
      } else {
        throw new Error('Update failed')
      }
    } catch (error) {
      console.warn(error)
      setIsActionCompleted(previousState) // ロールバック
      toast.methods.toast('更新に失敗しました。再度お試しください。')
    } finally {
      setIsLoading(false)
    }
  }

  if (isActionCompleted) {
    return (
      <div className="thread-comment-form is-action-completed">
        <div className="thread-action-completed-form__form">
          <div className="action-completed">
            <div className="action-completed__action">
              <button
                className={`a-button is-sm is-block check-button is-muted-borderd ${
                  isLoading ? 'is-inactive' : ''
                }`}
                onClick={handleClick}
                disabled={isLoading}>
                <i className="fas fa-check"></i>
                対応済です
              </button>
            </div>
            <div className="action-completed__description">
              <p>
                お疲れ様でした！
                相談者から次のアクションがあった際は、自動で未対応のステータスに変更されます。
                再度このボタンをクリックすると、未対応にステータスに戻ります。
              </p>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="thread-comment-form is-action-completed">
      <div className="thread-action-completed-form__form">
        <div className="action-completed">
          <div className="action-completed__action">
            <button
              className={`a-button is-sm is-block check-button is-warning ${
                isLoading ? 'is-inactive' : ''
              }`}
              onClick={handleClick}
              disabled={isLoading}>
              <i className="fas fa-redo"></i>
              対応済にする
            </button>
          </div>
          <div className="action-completed__description">
            <p>
              返信が完了し次は相談者からのアクションの待ちの状態になったとき、
              もしくは、相談者とのやりとりが一通り完了した際は、
              このボタンをクリックして対応済のステータスに変更してください。
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
