import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'

const source = (await readFile(new URL('../../app/javascript/performance.js', import.meta.url), 'utf8')).replace(/^import .*\n/gm, '')
const { collectPerformance } = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)

function surface({ hidden = false, mobile = false, unsupported = false } = {}) {
  const events = () => ({
    handlers: {},
    addEventListener(name, callback) { (this.handlers[name] ||= []).push(callback) },
    emit(name, extra = {}) { for (const callback of this.handlers[name] || []) callback({ target: this, ...extra }) }
  })
  const doc = Object.assign(events(), {
    visibilityState: hidden ? 'hidden' : 'visible',
    querySelector(selector) { return { content: selector.includes('token') ? 'signed-ticket' : 'reports_index' } }
  })
  const win = Object.assign(events(), {
    location: { href: 'https://example.invalid/reports' },
    matchMedia: () => ({ matches: mobile }),
    PerformanceObserver: { supportedEntryTypes: unsupported ? [] : ['largest-contentful-paint', 'event', 'layout-shift'] },
    PerformanceEventTiming: { prototype: { interactionId: 1 } }
  })
  win.top = win
  win.history = {
    pushState(_state, _title, url) { if (url) win.location.href = new URL(url, win.location.href).href },
    replaceState(_state, _title, url) { if (url) win.location.href = new URL(url, win.location.href).href }
  }
  const callbacks = {}
  const sends = []
  const observers = Object.fromEntries(['LCP', 'INP', 'CLS'].map((name) => [name, (callback, options) => {
    assert.equal(options.reportAllChanges, true)
    callbacks[name] = callback
  }]))
  collectPerformance({ window: win, document: doc, observers, send: (body) => { sends.push(JSON.parse(body)); return Promise.reject(new Error('lost')) } })
  return { win, doc, callbacks, sends }
}

const tick = () => new Promise((resolve) => setImmediate(resolve))

test('latest numeric snapshots send once on pagehide and missing INP never becomes zero', async () => {
  const { win, doc, callbacks, sends } = surface({ mobile: true })
  callbacks.LCP({ value: 1200, id: 'secret', entries: [{ target: 'private' }] })
  callbacks.CLS({ value: 0 })
  doc.emit('visibilitychange')
  assert.equal(sends.length, 0)
  callbacks.LCP({ value: 2600 })
  win.matchMedia = () => ({ matches: false })
  win.emit('pagehide')
  callbacks.LCP({ value: 99999 })
  win.emit('pagehide')
  await tick()
  assert.equal(sends.length, 1)
  assert.deepEqual(sends[0], { performance_report: {
    token: 'signed-ticket', page: 'reports_index', device: 'mobile',
    metrics: { LCP: { state: 'observed', value: 2600 }, INP: { state: 'unobserved' }, CLS: { state: 'observed', value: 0 } }
  } })
  assert.ok(Buffer.byteLength(JSON.stringify(sends[0])) <= 2048)
  assert.ok(!JSON.stringify(sends).includes('secret'))
})

test('initially hidden documents and iframes are not measured', async () => {
  const hidden = surface({ hidden: true })
  assert.deepEqual(hidden.callbacks, {})
  hidden.win.emit('pagehide')
  await tick()
  assert.equal(hidden.sends.length, 0)
})

test('bfcache restore cannot produce another sample', async () => {
  const { win, callbacks, sends } = surface()
  callbacks.LCP({ value: 500 })
  win.emit('pagehide')
  win.emit('pageshow', { persisted: true })
  callbacks.LCP({ value: 100 })
  win.emit('pagehide')
  await tick()
  assert.equal(sends.length, 1)
  assert.equal(sends[0].performance_report.metrics.LCP.value, 500)
})

test('Turbo top-level navigation, history transitions and popstate invalidate permanently', async () => {
  for (const navigate of [
    ({ doc }) => doc.emit('turbo:before-visit'),
    ({ doc }) => doc.emit('turbo:before-render'),
    ({ win }) => win.emit('popstate'),
    ({ win }) => { win.history.pushState({}, '', '/users'); win.history.replaceState({}, '', '/reports') },
    ({ win }) => { win.location.href = 'https://example.invalid/users' }
  ]) {
    const context = surface()
    context.callbacks.LCP({ value: 100 })
    navigate(context)
    context.callbacks.INP({ value: 100 })
    context.win.emit('pagehide')
    await tick()
    assert.equal(context.sends.length, 0)
  }
})

test('invalid callback values are dropped and known unsupported APIs remain explicit', async () => {
  const context = surface()
  for (const value of [-1, NaN, Infinity, '1', undefined]) context.callbacks.INP({ value })
  context.win.emit('pagehide')
  const unsupported = surface({ unsupported: true })
  unsupported.win.emit('pagehide')
  await tick()
  assert.deepEqual(context.sends[0].performance_report.metrics.INP, { state: 'unobserved' })
  assert.deepEqual(unsupported.sends[0].performance_report.metrics.INP, { state: 'unsupported' })
})
