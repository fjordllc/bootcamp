let MarkdownInitializer
let TextareaInitializer

async function loadMarkdownInitializer() {
  if (!MarkdownInitializer) {
    ;({ default: MarkdownInitializer } = await import(
      './markdown-initializer.js'
    ))
  }
  return MarkdownInitializer
}

async function loadTextareaInitializer() {
  if (!TextareaInitializer) {
    ;({ default: TextareaInitializer } = await import(
      './textarea-initializer.js'
    ))
  }
  return TextareaInitializer
}

export async function initializeTextarea(selector) {
  const initializer = await loadTextareaInitializer()
  initializer.initialize(selector)
}

export async function uninitializeTextarea(selector) {
  const initializer = await loadTextareaInitializer()
  initializer.uninitialize(selector)
}

export async function renderMarkdown(text) {
  const Initializer = await loadMarkdownInitializer()
  return new Initializer().render(text)
}

export async function replaceMarkdown(selector) {
  const Initializer = await loadMarkdownInitializer()
  new Initializer().replace(selector)
}
