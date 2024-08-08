import { OnBrowserJudge } from './onbrowserjudge.js'
import ace from 'ace-builds'
import 'ace-builds/webpack-resolver'
import 'ace-builds/src-noconflict/mode-javascript'
import 'ace-builds/src-noconflict/mode-ruby'
import 'ace-builds/src-noconflict/theme-github'

document.addEventListener('DOMContentLoaded', () => {
  const id = 'code_editor'
  const element = document.getElementById(id)
  if (!element) {
    return null
  }

  const language = element.dataset.language
  console.log(language)

  const editor = ace.edit(id)
  editor.session.setMode('ace/mode/javascript')
  editor.setTheme('ace/theme/github')

  OnBrowserJudge.workerFile = "../javascript.js"
  OnBrowserJudge.getProgram = () => editor.getValue()
  OnBrowserJudge.dict.ready = "▶実行"
  OnBrowserJudge.dict.running = "■停止"
  OnBrowserJudge.dict.preparation = "準備中"
  OnBrowserJudge.dict.case_name = "テストケース名"
  OnBrowserJudge.dict.status = "結果"
  OnBrowserJudge.dict.exec_time = "実行時間"
  OnBrowserJudge.dict.copy = "コピー"
  OnBrowserJudge.dict.copied = "コピーしました"
  OnBrowserJudge.dict.AC = "正解"
  OnBrowserJudge.dict.WA = "不正解"
  OnBrowserJudge.dict.RE = "エラー"
  OnBrowserJudge.dict.TLE = "時間超過"
  OnBrowserJudge.dict.WJ = "ジャッジ待ち"
  OnBrowserJudge.timeLimit = 2001
  OnBrowserJudge.process = (program, casename, input) => program
  OnBrowserJudge.assertEqual = (expected, actual) => expected == actual.trimEnd()
  OnBrowserJudge.congratulations = () => { alert("正解！") }
 })

