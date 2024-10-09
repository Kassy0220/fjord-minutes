import { useState, useCallback } from 'react'
import PropTypes from 'prop-types'
import sendRequest from '../sendRequest.js'
import useChannel from '../hooks/useChannel.js'

export default function OtherForm({ minuteId, content }) {
  const [inputValue, setInputValue] = useState(content)

  const onReceivedData = useCallback(function (data) {
    if ('minute' in data.body) {
      setInputValue(data.body.minute.other)
    }
  }, [])
  useChannel(minuteId, onReceivedData)

  const handleChange = function (e) {
    setInputValue(e.target.value)
  }

  const handleClick = async function (e) {
    e.preventDefault()
    const parameter = { minute: { other: inputValue } }

    const response = await sendRequest(
      `/api/minutes/${minuteId}`,
      'PATCH',
      parameter
    )

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
