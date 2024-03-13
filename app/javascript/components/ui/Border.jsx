import React from 'react'

const borderColors = {
  primary: 'a-border',
  tint: 'a-border-tint',
  shade: 'a-border-shade'
}

const Border = ({ color = 'primary' }) => <hr className={borderColors[color]} />

export { Border }
