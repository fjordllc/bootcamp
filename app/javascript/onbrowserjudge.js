const OnBrowserJudge = {
  dict: {
    ready: "▶Run",
    running: "■Stop",
    preparation: "In preparation",
    case_name: "Case Name",
    status: "Status",
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

  process: (program, _casename, _input) => program,

  assertEqual: (expected, actual) => expected === actual.trimEnd(),


  status: "preparation",

  updateStatus: function(status) {
    this.status = status
    const button = document.getElementById("run")
    button.disabled = status === "preparation"
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
    let d = null
    switch (e.data[0]) {
      case "init":
        this.worker.postMessage(["init", this.initialData])
        break
      case "ready":
        this.updateStatus("ready")
        break
      case "executed":
        d = e.data[1]
        this.executed(d.testCase, d.output, d.error, d.errorMessage, d.execTime)
        break
    }
  },

  loadWorker: function(path) {
    const baseURL = window.location.href.replaceAll("\\", "/").replace(/\/[^/]*$/, "/")
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
    if (this.status !== "ready") return
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
    this.updateResult(testCase, "TLE", '', '', '', this.timeLimit * 2)
    this.stop()
  },

  executed: function(testCase, output, error, errorMessage, execTime) {
    clearTimeout(this.timer)
    let result = "AC"
    if (error !== 0) {
      result = error === 1 ? "CE" : "RE"
    } else {
      if (execTime > this.timeLimit) result = "TLE"
      const expected = document.getElementById(`${testCase}_output`).innerText.trim()
      if (! this.assertEqual(expected, output)) result = "WA"
    }

    console.log('output:', output);
    console.log('error:', error);
    console.log('errorMessage:', errorMessage);

    this.updateResult(testCase, result, output, error, errorMessage, execTime)
    if (result !== "AC") this.allPassed = false
    if (this.restTests.length === 0) {
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
    <th>出力</th>
    <th>エラー</th>
    <th>${this.dict.status}</th>
</tr></thead>`

    for(const testCase of OnBrowserJudge.tests) {
      const tr = document.createElement("tr")
      tr.innerHTML = `
<td id="${testCase}">${testCase}</td>
<td id="${testCase}_std_output"><pre><code></code></pre></td></td>
<td id="${testCase}_std_error"><pre><code></code></pre></td>
<td id="${testCase}_status"><span class="status wj">${this.dict.WJ}</span></td>`
      document.getElementById("result").appendChild(tr)
    }
    document.getElementById("result").scrollIntoView({ behavior: "smooth" })
  },

  updateResult: function(testCase, result, output, _error, errorMessage, _execTime) {
    document.getElementById(`${testCase}_std_output`).innerHTML = `<pre><code>${output}</code></pre>`
    document.getElementById(`${testCase}_std_error`).innerHTML = `<pre><code>${errorMessage}</code></pre>`
    const span = `<span class="status ${result.toLowerCase()}` +
                 `" title="${result}">${this.dict[result]}</span>`
    document.getElementById(`${testCase}_status`).innerHTML = span
  },

  stop: function() {
    window.clearTimeout(this.timer)
    Array.from(document.getElementsByClassName("wj")).forEach((elm) => {
      elm.innerText = ""
    })

    this.updateStatus("preparation")
    this.resetWorker()
  },

  copyProgram: function() {
    navigator.clipboard.writeText(this.getProgram())
  }
}


window.addEventListener("DOMContentLoaded", () => {
  const editor = document.getElementById('code_editor')
  if (!editor) return null

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

  OnBrowserJudge.updateStatus("preparation")
  OnBrowserJudge.resetWorker()
  document.getElementById("run").onclick = () => OnBrowserJudge.runButtonPressed()
})

export { OnBrowserJudge }
