import { create } from 'zustand'

const getCheckableById = (checkableId, checkableType) => {
  return fetch(
    `/api/checks.json/?checkable_type=${checkableType}&checkable_id=${checkableId}`,
    {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin'
    }
  ).then((response) => {
    return response.json()
  })
}

const getWatchableById = (watchableId, watchableType) => {
  return fetch(
    `/api/watches/toggle.json?watchable_id=${watchableId}&watchable_type=${watchableType}`,
    {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin'
    }
  ).then((response) => {
    return response.json()
  })
}

const useZustandStore = create((set) => ({
  // 日報と提出物の確認状態の確認スタンプと確認ボタン、確認OKコメントボタンに使用
  // checkId: 確認したかどうかのデータのId (null|string)
  // isChecked: 確認しているかどうかの真偽値 (Boolean)
  // checkerUserName: 確認を担当したユーザーの名前 (null|string)
  // createdAt: 確認が行われた日時 (null|string)
  // checkableId: checkableのId (null|string)
  // checkableType: checkableの種類 現在は2種類のみ (null|string('Product'|'Report'))
  checkable: {
    checkId: null,
    isChecked: false,
    checkerUserName: null,
    createdAt: null,
    checkableId: null,
    checkableType: null,
    // 日報と提出物の確認状態の共有に使用
    setCheckable: async ({ checkableId, checkableType }) => {
      try {
        const checkable = await getCheckableById(checkableId, checkableType)
        set((state) => ({
          checkable: {
            ...state.checkable,
            checkId: checkable[0]?.id ?? null,
            isChecked: !!checkable[0]?.id ?? false,
            createdAt: checkable[0]?.created_at ?? null,
            checkerUserName: checkable[0]?.user?.login_name ?? null,
            checkableId,
            checkableType
          }
        }))
      } catch (error) {
        console.warn(error)
      }
    }
  },
  responsibleMentor: {
    // productId: 提出物のIdです Commentから担当者になるために使います
    productId: null,
    // responsibleMentorState: 提出物の担当者の状態を表します
    // 'absent' 担当者が存在しない場合
    // 'currentUser' ログインしているユーザーが担当者の場合
    // 'otherUser' ログインしているユーザーとは別の人が担当者の場合
    responsibleMentorState: 'absent',
    setInitialResponsibleMentorState: ({
      productId,
      responsibleMentorId,
      currentUserId
    }) => {
      const createResponsibleMentorState = ({
        responsibleMentorId,
        currentUserId
      }) => {
        if (!responsibleMentorId) {
          return 'absent'
        } else if (responsibleMentorId === currentUserId) {
          return 'currentUser'
        } else {
          return 'otherUser'
        }
      }

      const responsibleMentorState = createResponsibleMentorState({
        responsibleMentorId,
        currentUserId
      })

      set((state) => ({
        responsibleMentor: {
          ...state.responsibleMentor,
          productId,
          responsibleMentorState
        }
      }))
    },
    becomeResponsibleMentor: () => {
      set((state) => ({
        responsibleMentor: {
          ...state.responsibleMentor,
          responsibleMentorState: 'currentUser'
        }
      }))
    },
    absentResponsibleMentor: () => {
      set((state) => ({
        responsibleMentor: {
          ...state.responsibleMentor,
          responsibleMentorState: 'absent'
        }
      }))
    }
  },
  // watch-toggleコンポーネントで使用
  watch: {
    watchId: null,
    isWatched: false,
    // commentとwatch-toggleが同ページ内で共存しているページでの状態共有に使用
    setWatchable: async ({ watchableId, watchableType }) => {
      try {
        const watchable = await getWatchableById(watchableId, watchableType)
        set((state) => ({
          watch: {
            ...state.watch,
            watchId: watchable[0]?.id ?? null,
            isWatched: !!watchable[0]?.id ?? false
          }
        }))
      } catch (error) {
        console.warn(error)
      }
    }
  }
}))

export { useZustandStore }
