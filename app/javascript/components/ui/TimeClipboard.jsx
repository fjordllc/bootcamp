import React from 'react'
import { useClipboard } from '../../hooks/useClipboard'
import dayjs from 'dayjs'
import 'dayjs/locale/ja'
import clsx from 'clsx'

dayjs.locale('ja')

export const TimeClipboard = ({
  url,
  dateTime,
  className,
  dateFormat = 'YYYY年MM月DD日(dd) HH:mm',
  duration = 4000,
  ...props
}) => {
  const [isCopied, execCopy] = useClipboard(url, duration)
  const formattedDateTime = dayjs(dateTime).format(dateFormat)

  return (
    <time
      className={clsx({ 'is-active': isCopied }, className)}
      dateTime={dateTime}
      onClick={execCopy}
      {...props}
    >
      {formattedDateTime}
    </time>
  )
}
