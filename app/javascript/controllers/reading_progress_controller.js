import { Controller } from 'stimulus'
import { post } from '@rails/request.js'

export default class extends Controller {
  static values = {
    sectionId: Number,
    totalBlocks: Number
  }

  connect() {
    this.maxBlockSeen = -1
    this.completed = false
    this.debounceTimer = null

    this.blocks = this.element.querySelectorAll('[data-block-index]')
    this.totalBlocksValue = this.blocks.length

    if (this.blocks.length === 0) return

    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersection(entries),
      { threshold: 0.5 }
    )

    this.blocks.forEach((block) => this.observer.observe(block))
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  handleIntersection(entries) {
    entries.forEach((entry) => {
      const index = parseInt(entry.target.dataset.blockIndex, 10)
      if (entry.isIntersecting) {
        if (index > this.maxBlockSeen) {
          this.maxBlockSeen = index
        }
      }
    })

    this.debouncedUpdate()
  }

  debouncedUpdate() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
    this.debounceTimer = setTimeout(() => this.updateProgress(), 2000)
  }

  async updateProgress() {
    if (this.totalBlocksValue === 0) return
    if (this.maxBlockSeen < 0) return

    const readRatio = (this.maxBlockSeen + 1) / this.totalBlocksValue
    const isCompleted =
      this.maxBlockSeen >= this.totalBlocksValue - 1 && !this.completed

    try {
      const response = await post('/api/textbooks/reading_progresses', {
        body: {
          reading_progress: {
            textbook_section_id: this.sectionIdValue,
            last_block_index: this.maxBlockSeen,
            read_ratio: Math.min(readRatio, 1.0),
            completed: isCompleted || this.completed
          }
        }
      })

      if (isCompleted && response.ok) {
        this.completed = true
        this.dispatch('completed', {
          detail: { sectionId: this.sectionIdValue }
        })
      }
    } catch (error) {
      console.error('進捗の保存に失敗しました:', error)
    }
  }
}
