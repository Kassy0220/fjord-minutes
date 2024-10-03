import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

export default function mountComponent(id, Component) {
  const element = document.getElementById(id)
  if (element === null) {
    return null
  }

  const root = createRoot(element)
  const props = JSON.parse(element.getAttribute('data'))
  root.render(
    <StrictMode>
      <Component {...props} />
    </StrictMode>
  )
}
