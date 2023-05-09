import React, { useState, useCallback } from 'react'
import TagifyTags from '@yaireo/tagify/dist/react.tagify'
import '@yaireo/tagify/dist/tagify.css' // Tagify CSS
import useSWR from 'swr'
import fetcher from '../../fetcher'
import transformHeadSharp from './transform-head-sharp.js'
import validateTagName from './validate-tag-name'
import headIsSharpOrOctothorpe from './head-is-sharp-or-octothorpe'
import parseTags from './parse_tags'

export default function TagsInput({
  tagsInitialValue,
  tagsParamName,
  taggableType
}) {
  const [tags, setTags] = useState(parseTags(tagsInitialValue))
  const [isSharp, setIsSharp] = useState(false)
  const { data, error } = useSWR(
    `/api/tags.json?taggable_type=${taggableType}`,
    fetcher
  )

  if (error) {
    console.warn('使われているタグリストの読み込みに失敗しました', error)
  }

  const onInput = useCallback((e) => {
    setIsSharp(headIsSharpOrOctothorpe(e.detail.value))
  }, [])

  const onChange = useCallback((e) => {
    setTags(
      e.detail.tagify.value
        .filter((tag) => tag.__isValid)
        .map((tag) => tag.value)
    )
    setIsSharp(false)
  }, [])

  const onInvalid = useCallback((e) => {
    alert(e.detail.message)
    setIsSharp(false)
  }, [])

  return (
    <>
      <TagifyTags
        settings={{
          validate: validateTagName,
          transformTag: transformHeadSharp
        }}
        value={tags}
        whitelist={data ? data.map((tag) => tag.value) : []}
        onInput={onInput}
        onChange={onChange}
        onInvalid={onInvalid}
      />
      <input type="hidden" value={tags.join()} name={tagsParamName} />
      {isSharp && <div>先頭の記号は無視されます</div>}
    </>
  )
}
