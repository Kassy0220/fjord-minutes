import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

export default function mountComponent(className, Component) {
  const elements = document.getElementsByClassName(className)
  if (elements.length === 0) {
    return null
  }

  Array.from(elements).forEach((element) => {
    const root = createRoot(element)
    const props = JSON.parse(element.getAttribute('data'))
    root.render(
      <StrictMode>
        <Component {...props} />
      </StrictMode>
    )
  })
}
