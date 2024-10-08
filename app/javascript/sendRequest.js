export default function sendRequest(resource, method, parameter) {
  const csrfToken = document.head.querySelector(
    'meta[name=csrf-token]'
  )?.content

  return fetch(resource, {
    method: method,
    body: JSON.stringify(parameter),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-CSRF-Token': csrfToken,
    },
  })
}
