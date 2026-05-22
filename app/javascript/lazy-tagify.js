let Tagify

export default async function loadTagify() {
  if (!Tagify) {
    await import('@yaireo/tagify/dist/tagify.css')
    ;({ default: Tagify } = await import('@yaireo/tagify'))
  }
  return Tagify
}
