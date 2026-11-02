import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import test from 'node:test'
import vm from 'node:vm'

const root = new URL('../../', import.meta.url)
const read = (path) => readFileSync(new URL(path, root), 'utf8')

// Expand only the ERB constructs used by these tags; fail on unhandled markup.
function render(template, loggedIn = false) {
  const html = template
    .replace(/<%#[\s\S]*?%>/g, '')
    .replace(/<% if current_user %>([\s\S]*?)<% else %>([\s\S]*?)<% end %>/g,
      (_, signedIn, guest) => loggedIn ? signedIn : guest)
    .replace(/<%= render '([\w/]+)' %>/g,
      (_, name) => render(read(`app/views/application/_${name}.html.erb`), loggedIn))
  assert.ok(!html.includes('<%'), 'unhandled ERB in Google tag test')
  return html
}

function commonHead(loggedIn) {
  const partials = [...read('app/views/layouts/common/_common_head.html.slim')
    .matchAll(/^= render '(google_analytics|google_ads|promise_all_settled)'/gm)]
  return render(partials.map((match) => `<%= render '${match[1]}' %>`).join('\n'), loggedIn)
}

function browser(setup = '') {
  const context = vm.createContext({ document: { addEventListener() {} } })
  vm.runInContext(`window = this; ${setup}`, context)
  return context
}

function load(html, context, checkCompatibility = true) {
  const tags = []
  for (const [, attributes, source] of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script>/g)) {
    if (attributes.includes('googletagmanager.com/gtag/js')) {
      // An async tag can execute as soon as the parser reaches it.
      if (checkCompatibility) assert.equal(vm.runInContext('typeof Promise.allSettled', context), 'function')
      tags.push(attributes.match(/id=([^"&]+)/)[1])
    } else if (!attributes.includes('src=')) {
      vm.runInContext(source, context)
    }
  }
  return tags
}

for (const [name, page, ids] of [
  ['logged-in layout', () => commonHead(true), ['G-EYY9JK69GX', 'AW-17419900911']],
  ['guest layout', () => commonHead(false), ['AW-17419900911', 'G-WWN96PXWSW', 'AW-17419900911']],
  ['standalone campaign', () => render(read('app/views/static_pages/campaign_basic.html.erb').split('</head>')[0]), ['G-WWN96PXWSW']]
]) {
  test(`${name} supports allSettled before any Google tag and preserves tracking IDs`, () => {
    const context = browser('Promise.allSettled = undefined')
    assert.deepEqual(load(page(), context), ids)
    const configs = JSON.parse(vm.runInContext("JSON.stringify(dataLayer.filter(function (entry) { return entry[0] === 'config' }).map(function (entry) { return entry[1] }))", context))
    for (const id of ids) assert.ok(configs.includes(id))
  })
}

test('fallback waits for all outcomes, preserving input order and rejection reasons', async () => {
  const context = browser('Promise.allSettled = undefined')
  load(commonHead(false), context)
  const outcome = vm.runInContext(`
    var finish;
    var pending = new Promise(function (resolve) { finish = resolve });
    var reason = new Error('rejected');
    var settled = false;
    var outcome = Promise.allSettled(new Set([pending, Promise.reject(reason), 42,
      { then: function (resolve) { resolve('thenable') } }])).then(function (results) {
      settled = true;
      if (results[1].reason !== reason) throw new Error('reason identity lost');
      return results;
    });
    outcome;
  `, context)
  await new Promise((resolve) => setImmediate(resolve))
  assert.equal(vm.runInContext('settled', context), false)
  vm.runInContext("finish('first')", context)
  const result = await outcome
  assert.deepEqual(JSON.parse(JSON.stringify(result)), [
    { status: 'fulfilled', value: 'first' },
    { status: 'rejected', reason: {} },
    { status: 'fulfilled', value: 42 },
    { status: 'fulfilled', value: 'thenable' }
  ])
})

test('fallback handles empty input and rejects invalid input without throwing synchronously', async () => {
  const context = browser('Promise.allSettled = undefined')
  load(commonHead(false), context)
  assert.equal(JSON.stringify(await vm.runInContext('Promise.allSettled([])', context)), '[]')
  for (const expression of ['null', '{}', '{ [Symbol.iterator]: function () { throw new Error("iterator failed") } }']) {
    const result = vm.runInContext(`Promise.allSettled(${expression})`, context)
    await assert.rejects(result)
  }
})

test('existing native allSettled is preserved even when the partial runs twice', () => {
  const context = browser('original = Promise.allSettled')
  load(commonHead(false), context)
  load(commonHead(false), context)
  assert.equal(vm.runInContext('Promise.allSettled === original', context), true)
})

test('a browser without Promise can still initialize the tag queue', () => {
  const context = browser('Promise = undefined')
  load(commonHead(false), context, false)
  assert.ok(vm.runInContext('dataLayer.length > 0', context))
})
