/** 
 * @file OnBrowserJudge - for JavaScript
 * @author nodai2hITC
 * @license MIT License
 * @version v1.0.0
 */

"use strict"

self.postMessage(["init"])

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

      let output = ""
      const _readFileSync = {
        readFileSync: function(stdin, encoding){
          if (stdin != "/dev/stdin" || encoding != "utf8") throw "readFileSync error"
          return input
        }
      }
      const _console = { log: function(text) { output += text + "\n" } }
      const _require = function(fs) {
        if (fs != "fs") throw "require error"
        return _readFileSync
      }
      
      let error = 0
      let errorMessage = ""
      const startTime = performance.now()
      try {
        (new Function("console", "require", program))(_console, _require)
      } catch(err) {
        errorMessage = err.toString()
        error = 2
      }
      const execTime = performance.now() - startTime
      self.postMessage(["executed", { testCase, output, error, errorMessage, execTime }])
  }
})
