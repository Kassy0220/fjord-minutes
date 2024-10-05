import { useState } from 'react'
import PropTypes from 'prop-types'

export default function OtherForm({ minuteId, content }) {
  const [inputValue, setInputValue] = useState(content)

  const handleChange = function (e) {
    setInputValue(e.target.value)
  }

  const handleClick = async function (e) {
    e.preventDefault()
    const parameter = { minute: { other: inputValue } }
    const csrfToken = document.head.querySelector(
      'meta[name=csrf-token]'
    )?.content

    const response = await fetch(`/api/minutes/${minuteId}`, {
      method: 'PATCH',
      body: JSON.stringify(parameter),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-CSRF-Token': csrfToken,
      },
    })

    if (response.status !== 200) {
      const errorData = await response.json()
      console.error(errorData.errors.join(','))
    }
  }

  return (
    <>
      <textarea
        value={inputValue}
        onChange={handleChange}
        className="w-[400px] resize-y align-middle field-sizing-content"
      />
      <button
        type="button"
        onClick={handleClick}
        className="ml-2 py-1 px-2 border border-black"
      >
        更新
      </button>
    </>
  )
}

OtherForm.propTypes = {
  minuteId: PropTypes.number,
  content: PropTypes.string,
}
