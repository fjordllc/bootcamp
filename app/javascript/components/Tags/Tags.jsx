import React, { useState, useCallback } from 'react'
import TagifyTags from "@yaireo/tagify/dist/react.tagify"
import "@yaireo/tagify/dist/tagify.css" // Tagify CSS
import useSWR from 'swr'
import fetcher from '../../fetcher'
import { token } from '../../utils'
import transformHeadSharp from './transform-head-sharp'
import validateTagName from './validate-tag-name'
import headIsSharpOrOctothorpe from './head-is-sharp-or-octothorpe'
import parseTags from './parse_tags'

export default function Tags({
  tagsInitialValue,
  tagsParamName,
  tagsInputId,
  tagsType,
  tagsTypeId
}) {
  const [tags, setTags] = useState(parseTags(tagsInitialValue))
  const [editing, setEditing] = useState(false)
  const [isSharp, setIsSharp] = useState(false)
  const { data, error } = useSWR(`/api/tags.json?taggable_type=${tagsType}`, fetcher)

  if (error) {
    console.warn('使われているタグリストの読み込みに失敗しました', error)
  }

  const onChange = useCallback((e) => {
    setTags(e.detail.tagify.value
      .filter((tag) => tag.__isValid)
      .map((tag) => tag.value))
  }, [])

  const onInput = useCallback((e) => {
    setIsSharp(headIsSharpOrOctothorpe(e.detail.value))
  }, [])

  const onCancel = useCallback((e) => {
    e.preventDefault()
    setTags(parseTags(tagsInitialValue))
    setEditing(false)
  }, [])

  const onInvalid = useCallback((e) => {
    alert(e.detail.message)
    setIsSharp(false)
  }, [])

  const updateTag = (e) => {
    e.preventDefault()
    const params = {
      [tagsType.toLowerCase()]: {
        tag_list: tags.join()
      }
    }

    fetch(`/api/${tagsType.toLowerCase()}s/${tagsTypeId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': token()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    }).catch((error) => {
      alert('タグの更新に失敗しました')
      console.warn(error)
    }).finally(() => setEditing(false))
  }

  return (
    <div className="tag-links">
      {!editing &&
        <ul className="tag-links__items">
          {tags.map((tag) => {
            return (
              <li key={tag} className="tag-links__item">
                <a className="tag-links__item-link" href={`tags/${encodeURIComponent(tag)}`}>
                  { tag }
                </a>
              </li>
            )
          })}
          <li className="tag-links__item">
            <div className="tag-links__item-edit" onClick={() => setEditing(true)}>タグ編集</div>
          </li>
        </ul>
      }
      <form className={`${editing ? '' : 'hidden'}`}>
        <div className="form__items">
          <div className="form-item">
            <TagifyTags
              settings={{
                validate: validateTagName,
                transformTag: transformHeadSharp
              }}
              defaultValue={tags}
              whitelist={data ? data.map((tag) => tag.value) : []}
              onChange={onChange}
              onInput={onInput}
              onInvalid={onInvalid}
            />
            <input type="hidden" value={tags.join()} name={tagsParamName} id={tagsInputId}/>
          </div>
        </div>
        {isSharp && <div>先頭の記号は無視されます</div>}
        <div className="form-actions">
          <ul className="form-actions__items">
            <li className="form-actions__item is-main">
              <button className="a-button is-primary is-sm is-block" onClick={updateTag}>保存する</button>
            </li>
            <li className="form-actions__item">
              <button className="a-button is-sm is-text" onClick={onCancel}>キャンセル</button>
            </li>
          </ul>
        </div>
      </form>
    </div>
  )
}
