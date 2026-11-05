import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'

const source = await readFile(new URL('../../app/javascript/tribute-menu-events.js', import.meta.url), 'utf8')
const { default: guardTributeMenuClicks } = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)

function node(nodeName, parentNode = null) {
  return {
    nodeName, parentNode,
    contains(target) {
      while (target) {
        if (target === this) return true
        target = target.parentNode
      }
      return false
    }
  }
}

function setup() {
  const menu = node('DIV', node('LI'))
  const list = node('UL', menu)
  const item = node('LI', list)
  const nested = node('SPAN', item)
  const calls = []
  const tribute = { menu, events: {
    click(instance, event) { calls.push({ receiver: this, instance, event }); return 'selected' }
  } }
  const instance = { tribute }
  guardTributeMenuClicks(tribute)
  return { tribute, instance, menu, list, item, nested, calls }
}

test('ignores menu and list background even when an li exists outside the menu', () => {
  const { tribute, instance, menu, list, calls } = setup()
  for (const target of [menu, list]) tribute.events.click(instance, { target })
  assert.deepEqual(calls, [])
})

test('delegates candidate and nested text clicks with original receiver, arguments and result', () => {
  const { tribute, instance, item, nested, calls } = setup()
  for (const target of [item, nested, node('#text', nested)]) {
    const event = { target }
    assert.equal(tribute.events.click(instance, event), 'selected')
    assert.deepEqual(calls.at(-1), { receiver: tribute.events, instance, event })
  }
  assert.equal(calls.length, 3)
})

test('delegates outside clicks and clicks before the menu has been created', () => {
  const { tribute, instance, calls } = setup()
  const event = { target: node('BUTTON') }
  tribute.events.click(instance, event)
  tribute.menu = null
  tribute.events.click(instance, event)
  assert.equal(calls.length, 2)
})

test('unexpected errors from the original handler still propagate', () => {
  const error = new Error('unexpected selection error')
  const tribute = { events: { click() { throw error } } }
  guardTributeMenuClicks(tribute)
  assert.throws(() => tribute.events.click({ tribute }, { target: node('BUTTON') }), (actual) => actual === error)
})
