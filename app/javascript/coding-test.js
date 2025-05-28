import { OnBrowserJudge } from './onbrowserjudge.js'
import ace from 'ace-builds'
import 'ace-builds/webpack-resolver'
import 'ace-builds/src-noconflict/mode-javascript'
import 'ace-builds/src-noconflict/mode-ruby'
import 'ace-builds/src-noconflict/theme-github'
import Bootcamp from 'bootcamp'

document.addEventListener('DOMContentLoaded', () => {
  const id = 'code_editor'
  const element = document.getElementById(id)
  if (!element) {
    return null
  }

  const codingTestId = element.dataset.codingTestId
  const practiceId = element.dataset.practiceId
  const language = element.dataset.language
  const editor = ace.edit(id)

  editor.session.setMode(`ace/mode/${language}`)
  editor.setTheme('ace/theme/github')

  OnBrowserJudge.workerFile = `../${language}.js`
  OnBrowserJudge.getProgram = () => editor.getValue()
  OnBrowserJudge.dict.ready = '実行'
  OnBrowserJudge.dict.running = '停止'
  OnBrowserJudge.dict.preparation = '準備中'
  OnBrowserJudge.dict.case_name = 'テストケース名'
  OnBrowserJudge.dict.status = '結果'
  OnBrowserJudge.dict.AC = '正解'
  OnBrowserJudge.dict.WA = '不正解'
  OnBrowserJudge.dict.RE = 'エラー'
  OnBrowserJudge.dict.TLE = '時間超過'
  OnBrowserJudge.dict.WJ = 'ジャッジ待ち'
  OnBrowserJudge.timeLimit = 2001
  OnBrowserJudge.process = (program, _casename, _input) => program
  OnBrowserJudge.assertEqual = (expected, actual) => {
    console.log(`expected: ${expected}, actual: ${actual}`)
    console.log(expected === actual.trimEnd())
    return expected === actual.trimEnd()
  }
  OnBrowserJudge.congratulations = async () => {
    alert('正解！')

    const params = {
      coding_test_submission: {
        coding_test_id: codingTestId,
        code: editor.getValue()
      }
    }

    try {
      const response = await Bootcamp.post(
        '/api/coding_test_submissions',
        params
      )
      if (response.ok) {
        location.href = `/practices/${practiceId}`
      } else {
        console.warn('実行に失敗しました。')
      }
    } catch (error) {
      console.error(error)
    }
  }
})
