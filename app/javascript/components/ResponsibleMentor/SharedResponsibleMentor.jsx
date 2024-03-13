import React from 'react'
import ResponsibleMentorPresenter from './Presenter'
import {
  useInitializeResponsibleMentor,
  useResponsibleMentor
} from './useResponsibleMentor'

export default function SharedResponsibleMentor({
  responsibleUserId,
  responsibleUserName,
  responsibleUserAvatar,
  currentUserId,
  productId,
}) {
  useInitializeResponsibleMentor({
    initialResponsibleMentorId: responsibleUserId,
    productId,
    currentUserId
  })
  const {
    responsibleMentorState,
    handleBecomeResponsibleMentor,
    handleDeleteResponsibleMentor
  } = useResponsibleMentor()

  return (
    <ResponsibleMentorPresenter
      responsibleUserName={responsibleUserName}
      responsibleUserAvatar={responsibleUserAvatar}
      responsibleMentorState={responsibleMentorState}
      onBecomeResponsibleMentor={() => handleBecomeResponsibleMentor({ currentUserId })}
      onDeleteResponsibleMentor={handleDeleteResponsibleMentor}
    />
  )
}
