/** 
 * @file OnBrowserJudge - for Ruby
 * @author nodai2hITC
 * @license MIT License
 * @version v1.0.0
 */

"use strict"

const script = "https://cdn.jsdelivr.net/npm/ruby-head-wasm-wasi@0.5.0-2022-12-19-a/dist/browser.umd.js"
const wasm = "https://cdn.jsdelivr.net/npm/ruby-head-wasm-wasi@0.5.0-2022-12-19-a/dist/ruby+stdlib.wasm"

importScripts(script)
let RubyModule
const { DefaultRubyVM } = this["ruby-wasm-wasi"]
const main = async () => {
  const response = await fetch(wasm)
  const buffer = await response.arrayBuffer()
  RubyModule = await WebAssembly.compile(buffer)
  self.postMessage(["init"])
}
main()

self.addEventListener("message", async function(e) {
  switch (e.data[0]) {
    case "init":
      this.self.postMessage(["ready"])
      break
    case "execute":
      const data = e.data[1]
      const testCase = data.testCase
      const program  = data.program
      const input    = data.input
      const { vm } = await DefaultRubyVM(RubyModule)
      vm.eval(`
require 'stringio'
$stdin = StringIO.new('${input.replaceAll("\\", "\\\\").replaceAll("'", "\\'")}', 'r')
$stdout = $stderr = StringIO.new(+'', 'w')
      `)
      let output = ""
      let error = 0
      let errorMessage = ""
      const startTime = performance.now()
      try {
        vm.eval(program)
        output = vm.eval("$stdout.string").toString()
      } catch(err) {
        errorMessage = err.toString()
        error = 2
      }
      const execTime = performance.now() - startTime
      self.postMessage(["executed", { testCase, output, error, errorMessage, execTime }])
  }
})
