import React, { useState } from 'react'
import TagEditModal from './TagEditModal'

export default function TagEditButton({ tagId, tagName }) {
  const [showModal, setShowModal] = useState(false)

  return (
    <div className="w-full">
      <button
        className="a-button is-md is-secondary is-block"
        onClick={() => setShowModal(true)}>
        <i className="fa-solid fa-cog"></i>
        タグ名変更
      </button>
      {showModal && (
        <TagEditModal
          tagId={tagId}
          initialTagName={tagName}
          setShowModal={setShowModal}
        />
      )}
    </div>
  )
}
