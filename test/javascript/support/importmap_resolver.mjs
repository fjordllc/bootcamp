// config/importmap.rb と同じ名前でモジュールを読み込めるようにする。
// vendor/javascript と app/javascript に置いてあるものだけが対象で、CDN から読み込むものは解決しない。
import { existsSync } from 'node:fs'
import { registerHooks } from 'node:module'

const directories = ['vendor/javascript', 'app/javascript'].map(
  (directory) => new URL(`../../../${directory}/`, import.meta.url)
)

registerHooks({
  resolve(specifier, context, nextResolve) {
    if (/^[a-z@]/i.test(specifier) && !specifier.includes(':')) {
      for (const directory of directories) {
        const url = new URL(`${specifier}.js`, directory)
        if (existsSync(url)) return { url: url.href, format: 'module', shortCircuit: true }
      }
    }
    return nextResolve(specifier, context)
  }
})
