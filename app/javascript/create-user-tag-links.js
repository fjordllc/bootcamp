export default function createUserTagLinks(user) {
  const tags = user.tag_list
  if (!tags || tags.length === 0) return null

  const tagLinksDiv = document.createElement('div')
  tagLinksDiv.className = 'tag-links'

  const ul = document.createElement('ul')
  ul.className = 'tag-links__items'

  const frag = document.createDocumentFragment()
  tags.forEach((tag) => {
    const tagString = String(tag).trim()
    if (!tagString) return

    const li = document.createElement('li')
    li.className = 'tag-links__item'

    const a = document.createElement('a')
    a.className = 'tag-links__item-link'
    a.href = `/users/tags/${encodeURIComponent(tagString)}`
    a.textContent = tagString

    li.appendChild(a)
    frag.appendChild(li)
  })

  ul.appendChild(frag)
  tagLinksDiv.appendChild(ul)
  return tagLinksDiv
}
