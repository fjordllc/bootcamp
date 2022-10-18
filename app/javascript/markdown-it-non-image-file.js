export default function (md) {

  const defaultRender = md.renderer.rules.image
  const pattern = /\.[pgj][nip][gfe]*/;

  md.renderer.rules.image = function (tokens, idx, options, env, self) {
    const token = tokens[idx]
    const path = token.attrs[0][1]
    const fileName = token.content

    if(!pattern.test(path)) {
      return `<a href="${path}">${fileName}</a>\n`
    }

    return defaultRender(tokens, idx, options, env, self);
  };
}

