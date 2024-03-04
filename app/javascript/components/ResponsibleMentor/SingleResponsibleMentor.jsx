import React from 'react'
import ResponsibleMentorPresenter from './Presenter'
import {
  useResponsibleMentor
} from './useSingleResponsibleMentor'

export default function SingleResponsibleMentor({
  responsibleUserId,
  responsibleUserName,
  responsibleUserAvatar,
  currentUserId,
  productId,
}) {
  const {
    responsibleMentorState,
    handleBecomeResponsibleMentor,
    handleDeleteResponsibleMentor
  } = useResponsibleMentor({ responsibleMentorId: responsibleUserId, productId, currentUserId })

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
