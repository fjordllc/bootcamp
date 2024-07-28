/** 
 * @file OnBrowserJudge - mainfile
 * @author nodai2hITC
 * @license MIT License
 * @version v1.0.0
 */

"use strict"

const OnBrowserJudge = {
  dict: {
    ready: "▶Run",
    running: "■Stop",
    preparation: "In preparation",
    case_name: "Case Name",
    status: "Status",
    exec_time: "Exec Time",
    copy: "Copy",
    copied: "Copied.",
    AC: "AC",
    WA: "WA",
    RE: "RE",
    CE: "CE",
    IE: "IE",
    TLE: "TLE",
    MLE: "MLE",
    OLE: "OLE",
    WJ: "WJ"
  },

  timeLimit: 2000,

  initialData: null,

  congratulations: () => {},

  process: (program, casename, input) => program,

  assertEqual: (expected, actual) => expected == actual.trimEnd(),


  status: "preparation",

  updateStatus: function(status) {
    this.status = status
    const button = document.getElementById("run")
    button.disabled = status == "preparation"
    button.innerHTML = this.dict[status]
  },

  runButtonPressed: function() {
    switch (this.status) {
      case "ready":
        this.run()
        break
      case "running":
        this.stop()
        break
    }
  },

  worker: null,

  timer: null,

  workerEvent: function(e) {
    switch (e.data[0]) {
      case "init":
        this.worker.postMessage(["init", this.initialData])
        break
      case "ready":
        this.updateStatus("ready")
        break
      case "executed":
        const d = e.data[1]
        this.executed(d.testCase, d.output, d.error, d.execTime)
        break
    }
  },

  loadWorker: function(path) {
    const baseURL = window.location.href.replaceAll("\\", "/").replace(/\/[^\/]*$/, "/")
    const array = [`importScripts("${baseURL}${path}");`]
    const blob = new Blob(array, { type: "text/javascript" })
    const url = window.URL.createObjectURL(blob)
    return new Worker(url)
  },

  resetWorker: function() {
    if (this.worker) this.worker.terminate()
    this.worker = this.loadWorker(this.workerFile)
    this.worker.addEventListener("message", event => { this.workerEvent(event) }, false)
  },

  run: async function() {
    if (this.status != "ready") return
    this.updateStatus("running")
    const autocopy = document.getElementById("autocopy")
    if (!autocopy || autocopy.checked) this.copyProgram()
    this.initializeResult()
    this.restTests = Array.from(this.tests)
    this.allPassed = true
    this.program = this.getProgram()
    this.nextTest()
  },

  nextTest: function() {
    const testCase = this.restTests.shift()
    const input = document.getElementById(`${testCase}_input`).innerText.trim()
    const program = this.process(this.getProgram(), testCase, input)
    this.timer = setTimeout(() => this.tle(testCase), this.timeLimit * 2)
    this.worker.postMessage(["execute", { testCase, program, input }])
  },

  tle: function(testCase) {
    this.updateResult(testCase, "TLE", this.timeLimit * 2)
    this.stop()
  },

  executed: function(testCase, output, error, execTime) {
    clearTimeout(this.timer)
    let result = "AC"
    if (error != 0) {
      result = error == 1 ? "CE" : "RE"
    } else {
      if (execTime > this.timeLimit) result = "TLE"
      const expected = document.getElementById(`${testCase}_output`).innerText.trim()
      if (! this.assertEqual(expected, output)) result = "WA"
    }

    this.updateResult(testCase, result, execTime)
    if (result != "AC") this.allPassed = false
    if (this.restTests.length == 0) {
      if (this.allPassed) setTimeout(this.congratulations, 20)
      this.updateStatus("ready")
    } else {
      this.nextTest()
    }
  },

  initializeResult: function() {
    document.getElementById("result").innerHTML = `
<thead><tr>
    <th>${this.dict.case_name}</th>
    <th>${this.dict.status}</th>
    <th>${this.dict.exec_time}</th>
</tr></thead>`

    for(const testCase of OnBrowserJudge.tests) {
      const tr = document.createElement("tr")
      tr.innerHTML = `
<td id="${testCase}">${testCase}</td>
<td id="${testCase}_status"><span class="status wj">${this.dict.WJ}</span></td>
<td id="${testCase}_time"></td>`
      document.getElementById("result").appendChild(tr)
    }
    document.getElementById("result").scrollIntoView({ behavior: "smooth" })
  },

  updateResult: function(testCase, result, execTime) {
    const span = `<span class="status ${result.toLowerCase()}` +
                 `" title="${result}">${this.dict[result]}</span>`
    const time = execTime.toFixed(0) + " ms"
    document.getElementById(`${testCase}_status`).innerHTML = span
    document.getElementById(`${testCase}_time`).innerText = time
  },

  stop: function() {
    window.clearTimeout(this.timer)
    Array.from(document.getElementsByClassName("wj")).forEach(elm => elm.innerText = "")
    this.updateStatus("preparation")
    this.resetWorker()
  },

  copyProgram: function() {
    navigator.clipboard.writeText(this.getProgram())
  }
}


window.addEventListener("DOMContentLoaded", () => {
  function getTestNames() {
    return Array.from(document.getElementsByTagName("pre")).map(elm =>
      elm.id
    ).filter(id =>
      id.match(/_input$/) && document.getElementById(id.replace(/_input$/, "_output"))
    ).map(id => 
      id.replace(/_input$/, "")
    )
  }
  OnBrowserJudge.tests = getTestNames()

  function trimAllSampleCases() {
    const samples = document.getElementsByClassName("sample")
    for (const elm of samples) elm.innerText = elm.innerText.trim()
  }
  trimAllSampleCases()

  function addCopyButton(elms) {
    for (const elm of elms) {
      if (elm.id == "") continue
      let button = document.getElementById(elm.id + "_copy")
      if (!button) {
        button = document.createElement("button")
        button.id = elm.id + "_copy"
        button.innerHTML = OnBrowserJudge.dict.copy
        button.className = "copy"
        elm.parentNode.insertBefore(button, elm)
      }
      button.onclick = function() {
        navigator.clipboard.writeText(elm.innerText)
        this.innerHTML = OnBrowserJudge.dict.copied
        setTimeout(() => { this.innerHTML = OnBrowserJudge.dict.copy }, 1500)
      }
    }
  }
  addCopyButton(document.getElementsByClassName("sample"))

  OnBrowserJudge.updateStatus("preparation")
  OnBrowserJudge.resetWorker()
  document.getElementById("run").onclick = () => OnBrowserJudge.runButtonPressed()
})

export { OnBrowserJudge }
