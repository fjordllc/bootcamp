import React, { useState } from 'react';
import TagEditModal from './TagEditModal';

export default function TagEditButton ({ tagId, tagName }) {
  const [showModal, setShowModal] = useState(false);

  const openModal = () => {
    setShowModal(true);
  };

  return (
    <div className="page-main-header-actions__item">
      <button className="a-button is-sm is-secondary is-block" onClick={openModal}>
        <i className="fa-solid fa-cog"></i>
        タグ名変更
      </button>
      {showModal && (
        <TagEditModal
          tagId={tagId}
          propTagName={tagName}
          setShowModal={setShowModal}
        />
      )}
    </div>
  );
};
