import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'

async function load(name) {
  const source = await readFile(new URL(`../../app/javascript/${name}.js`, import.meta.url), 'utf8')
  const module = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
  return module.default
}

const validateTagName = await load('validate-tag-name')
const transformHeadSharp = await load('transform-head-sharp')
const headIsSharpOrOctothorpe = await load('head-is-sharp-or-octothorpe')
const parseTags = await load('parse_tags')

test('accepts ordinary tag names', () => {
  for (const value of ['Ruby', '猫', 'C#', 'Node.js', '.NET', '..']) {
    assert.equal(validateTagName({ value }), true, value)
  }
})

test('rejects tag names that contain whitespace', () => {
  for (const value of ['半角スペースは 使えない', '全角スペースも　使えない', 'タブも\t使えない', ' 先頭', '末尾 ']) {
    assert.equal(validateTagName({ value }), 'スペースを含むタグは作成できません', JSON.stringify(value))
  }
})

test('rejects a tag name that is a single dot', () => {
  assert.equal(validateTagName({ value: '.' }), 'ドット1つだけのタグは作成できません')
})

test('rejects tag names that still begin with a sharp', () => {
  for (const value of ['#Ruby', '＃Ruby', '♯Ruby']) {
    assert.equal(validateTagName({ value }), '#を先頭に含むタグは作成できません', value)
  }
})

test('removes one leading sharp before validation', () => {
  const cases = { '#Ruby': 'Ruby', '＃Ruby': 'Ruby', '♯Ruby': 'Ruby', '#': '', 'C#': 'C#', '##Ruby': '#Ruby' }
  for (const [input, expected] of Object.entries(cases)) {
    const tagData = { value: input }
    transformHeadSharp(tagData)
    assert.equal(tagData.value, expected, input)
  }
})

test('detects a leading sharp while typing', () => {
  for (const value of ['#', '#Ruby', '＃Ruby', '♯Ruby']) assert.equal(headIsSharpOrOctothorpe(value), true, value)
  for (const value of ['Ruby', 'C#', '', undefined]) assert.equal(headIsSharpOrOctothorpe(value), false, String(value))
})

test('parses a comma separated tag list', () => {
  assert.deepEqual(parseTags('Ruby,Rails'), ['Ruby', 'Rails'])
  assert.deepEqual(parseTags(''), [])
  assert.deepEqual(parseTags(undefined), [])
})
