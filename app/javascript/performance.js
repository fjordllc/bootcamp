import { FetchRequest } from '@rails/request.js'
import { onLCP, onINP, onCLS } from 'web-vitals'

// Only latest numeric values survive callbacks. No Metric object is retained.
export function collectPerformance({
  window: win,
  document: doc,
  observers,
  send
}) {
  const page = doc.querySelector('meta[name="performance-page"]')?.content
  const token = doc.querySelector('meta[name="performance-token"]')?.content
  if (
    !page ||
    !token ||
    win.top !== win ||
    doc.visibilityState !== 'visible' ||
    doc.prerendering
  )
    return

  const initialUrl = win.location.href
  const device = win.matchMedia('(max-width: 767px)').matches
    ? 'mobile'
    : 'desktop'
  const supported = win.PerformanceObserver?.supportedEntryTypes || []
  const metrics = {}
  const types = {
    LCP: 'largest-contentful-paint',
    INP: 'event',
    CLS: 'layout-shift'
  }
  let invalid = false
  let sent = false
  const invalidate = () => {
    invalid = true
  }
  const changed = () => win.location.href !== initialUrl
  for (const [name, type] of Object.entries(types)) {
    const available =
      supported.includes(type) &&
      (name !== 'INP' ||
        'interactionId' in (win.PerformanceEventTiming?.prototype || {}))
    metrics[name] = { state: available ? 'unobserved' : 'unsupported' }
    if (available) {
      observers[name](
        (metric) => {
          if (invalid || sent || changed()) return
          const value = metric.value
          if (typeof value === 'number' && Number.isFinite(value) && value >= 0)
            metrics[name] = { state: 'observed', value }
        },
        { reportAllChanges: true }
      )
    }
  }
  doc.addEventListener('turbo:before-visit', invalidate)
  doc.addEventListener('turbo:before-render', (event) => {
    if (
      !event.target ||
      event.target === doc ||
      event.target === doc.documentElement
    )
      invalidate()
  })
  win.addEventListener('popstate', invalidate)
  win.addEventListener('pageshow', (event) => {
    if (event.persisted) invalidate()
  })
  // History API changes must invalidate even if a router returns to the same URL.
  for (const method of ['pushState', 'replaceState']) {
    const original = win.history[method]
    win.history[method] = function (...args) {
      const result = original.apply(this, args)
      if (changed()) invalidate()
      return result
    }
  }
  win.addEventListener('pagehide', () => {
    if (sent) return
    sent = true
    if (invalid || changed()) return
    const body = JSON.stringify({
      performance_report: { token, page, device, metrics }
    })
    if (new TextEncoder().encode(body).length > 2048) return
    try {
      Promise.resolve(send(body)).catch(() => {})
    } catch {
      // Navigation must proceed even when a transport fails synchronously.
    }
  })
}

if (typeof window !== 'undefined') {
  collectPerformance({
    window,
    document,
    observers: { LCP: onLCP, INP: onINP, CLS: onCLS },
    send: (body) =>
      new FetchRequest('post', '/api/performance_reports', {
        body,
        responseKind: 'json',
        keepalive: true,
        credentials: 'same-origin',
        redirect: 'error'
      }).perform()
  })
}
