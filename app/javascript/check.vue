<template>
  <div>
    <hr class="a-border-tint" />
    <div class="card-footer is-only-mentor">
      <div class="card-main-actions">
        <ul class="card-main-actions__items">
          <li
            v-if="checkableType === 'Product'"
            class="card-main-actions__item">
            <!--
              v-showではなくv-ifだと "提出物を確認" => "取り消し" した際、
              担当ボタンの表示はページ読み込み時に戻る。
              例えば、ページ読み込み時に "担当する" ボタンだった場合、
              クリックして "担当から外れる" ボタンに変更後、
              "提出物を確認" => "取り消し" すると、
              ページ読み込み時の "担当する" ボタンが表示される。
              パフォーマンスが非常に悪くなるとかではないので、今回はv-showを利用
              checkerIdの値がページ読み込み時の値のままではなく、
              現状のcheckerIdを参照すれば、v-ifでも大丈夫と推測
            -->
            <product-checker
              v-show="checkId === null"
              :checker-id="checkerId"
              :checker-name="checkerName"
              :checker-avatar="checkerAvatar"
              :current-user-id="currentUserId"
              :product-id="checkableId"
              :checkable-type="checkableType"
              :parent-component="'check'"></product-checker>
          </li>
          <li class="card-main-actions__item" :class="checkId ? 'is-sub' : ''">
            <button
              id="js-shortcut-check"
              class="is-block"
              :class="
                checkId
                  ? 'card-main-actions__muted-action'
                  : 'a-button is-sm is-danger'
              "
              @click="checkSad">
              {{ buttonLabel }}
            </button>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>
<script>
import 'whatwg-fetch'
import CSRF from 'csrf'
import ProductChecker from 'product_checker'
import checkable from 'checkable.js'
import { toast } from 'vanillaToast.js'

export default {
  components: {
    'product-checker': ProductChecker
  },
  mixins: [checkable],
  props: {
    checkableId: { type: Number, required: true },
    checkableType: { type: String, required: true },
    checkableLabel: { type: String, required: true },
    checkerId: { type: Number, required: true },
    checkerName: { type: String, required: false, default: null },
    checkerAvatar: { type: String, required: false, default: null },
    currentUserId: { type: Number, required: false, default: null }
  },
  computed: {
    checkId() {
      return this.$store.getters.checkId
    },
    buttonLabel() {
      const path = window.location.pathname
      if (path.includes('/products')) {
        return (
          this.checkableLabel +
          (this.checkId ? 'の合格を取り消す' : 'を合格にする')
        )
      } else {
        return (
          this.checkableLabel + (this.checkId ? 'の確認を取り消す' : 'を確認')
        )
      }
    },
    url() {
      return this.checkId ? `/api/checks/${this.checkId}` : '/api/checks'
    },
    method() {
      return this.checkId ? 'DELETE' : 'POST'
    },
    checkHasSadEmotion() {
      const sadEmotion = document.querySelector('#sad')
      return sadEmotion !== null
    },
    checkHasComment() {
      const numberOfComments = parseInt(
        document.querySelector('a[href="#comments"] > span').innerHTML
      )
      return numberOfComments > 0
    }
  },
  methods: {
    toast(...args) {
      toast(...args)
    },
    checkSad() {
      if (this.checkHasSadEmotion && !this.checkHasComment && !this.checkId) {
        if (
          window.confirm(
            '今日の気分は「sad」ですが、コメント無しで確認しますか？'
          )
        ) {
          this.check(
            this.checkableType,
            this.checkableId,
            this.url,
            this.method,
            CSRF.getToken()
          )
        }
      } else {
        this.check(
          this.checkableType,
          this.checkableId,
          this.url,
          this.method,
          CSRF.getToken()
        )
      }
    }
  }
}
</script>
