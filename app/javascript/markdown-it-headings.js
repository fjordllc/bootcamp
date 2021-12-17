import plugin from 'markdown-it-github-headings'

const options = {
  enableHeadingLinkIcons: true,
  prefixHeadingIds: true,
  prefix: 'user-content-',
  className: 'md-headings',
  linkIcon:
    '<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg>',
  resetSlugger: true,
  headerHeight: 60,
  delayScroll: 1000
}

function scrollOutHeader(target) {
  target.scrollIntoView(true)
  const scrolledY = window.scrollY
  if (scrolledY) {
    window.scroll(0, scrolledY - options.headerHeight)
  }
}

function addMarkdownHeadingsClickListener() {
  const targets = document.getElementsByClassName(options.className)

  for (let i = 0; i < targets.length; i++) {
    targets[i].addEventListener('click', function () {
      scrollOutHeader(targets[i])
    })
  }
}

function scrollToLocationHashMarkdownHeading() {
  if (!location.hash) return
  if (document.querySelector(':target')) return
  const postfix = decodeURI(location.hash.slice(1))
  const name = options.prefix + postfix
  const target = document.getElementById(name)
  scrollOutHeader(target)
}

export function initMarkdownItHeadings() {
  addMarkdownHeadingsClickListener()
  setTimeout(scrollToLocationHashMarkdownHeading, options.delayScroll)
}

export default function (md) {
  return plugin(md, options)
}
