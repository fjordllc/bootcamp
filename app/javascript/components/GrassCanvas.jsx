import React, { forwardRef } from 'react'

const GrassCanvas = forwardRef((_, ref) => {
  return (
    <canvas
      id="grass"
      className="a-grass"
      width="650px"
      height="130px"
      ref={ref}></canvas>
  )
})

export default GrassCanvas
