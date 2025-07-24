<template>
  <div class="card-list-item" :class="questionClass">
    <div class="card-list-item__inner">
      <div class="card-list-item__user">
        <a class="card-list-item__user-link" :href="question.user.url">
          <span :class="['a-user-role', roleClass, joiningStatusClass]">
            <img
              class="card-list-item__user-icon a-user-icon"
              :title="question.user.icon_title"
              :alt="question.user.icon_title"
              :src="question.user.avatar_url" />
          </span>
        </a>
      </div>
      <div class="card-list-item__rows">
        <div class="card-list-item__row">
          <div class="card-list-item-title">
            <div class="a-list-item-badge is-wip" v-if="question.wip">
              <span>WIP</span>
            </div>
            <h1 class="card-list-item-title__title" itemprop="name">
              <a
                class="card-list-item-title__link a-text-link"
                :href="question.url"
                itemprop="url"
                >{{ question.title }}</a
              >
            </h1>
          </div>
        </div>

        <div class="card-list-item__row" v-if="question.practice">
          <div class="card-list-item-meta">
            <div class="card-list-item-meta__items">
              <div class="card-list-item-meta__item">
                <a
                  class="a-meta is-practice"
                  :href="practiceUrl"
                  v-if="practiceUrl !== null">
                  {{ question.practice.title }}
                </a>
              </div>
            </div>
          </div>
        </div>

        <div class="card-list-item__row">
          <div class="card-list-item-meta">
            <div class="card-list-item-meta__items">
              <div class="card-list-item-meta__item" v-if="question.wip">
                <div class="a-meta">質問作成中</div>
              </div>
              <div class="card-list-item-meta__item">
                <a class="a-user-name" :href="`/users/${question.user.id}`">
                  {{ question.user.long_name }}
                </a>
              </div>
            </div>
          </div>
        </div>

        <div class="card-list-item__row">
          <div class="card-list-item-meta">
            <div class="card-list-item-meta__items">
              <div class="card-list-item-meta__item" v-if="!question.wip">
                <time class="a-meta">
                  <span class="a-meta__label">公開</span>
                  <span class="a-meta__value">{{ publishedAt }}</span>
                </time>
              </div>
              <div class="card-list-item-meta__item" v-if="!question.wip">
                <time class="a-meta">
                  <span class="a-meta__label">更新</span>
                  <span class="a-meta__value">{{ updatedAt }}</span>
                </time>
              </div>
              <div class="card-list-item-meta__item">
                <div class="a-meta" :class="[urgentClass]">
                  回答・コメント（{{ question.answers.size }}）
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="stamp is-circle is-solved" v-if="question.has_correct_answer">
        <div class="stamp__content is-icon">解</div>
        <div class="stamp__content is-icon">決</div>
      </div>
    </div>
  </div>
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default {
  props: {
    question: { type: Object, required: true }
  },
  computed: {
    updatedAt() {
      return dayjs(this.question.updated_at).format('YYYY年MM月DD日(dd) HH:mm')
    },
    publishedAt() {
      return dayjs(this.question.published_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    },
    hasAnswers() {
      return this.question.answers.size > 0
    },
    roleClass() {
      return `is-${this.question.user.primary_role}`
    },
    joiningStatusClass() {
      return this.question.user.joining_status === 'new-user'
        ? 'is-new-user'
        : ''
    },
    urgentClass() {
      return {
        'is-important': !this.hasAnswers
      }
    },
    questionClass() {
      if (this.question.has_correct_answer) {
        return 'is-solved'
      } else if (this.question.wip) {
        return 'is-wip'
      } else {
        return ''
      }
    },
    practiceUrl() {
      return this.question.practice === undefined
        ? null
        : `/practices/${this.question.practice.id}`
    }
  }
}
</script>
