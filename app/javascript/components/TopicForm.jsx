import { useState } from 'react'
import PropTypes from 'prop-types'
import sendRequest from '../sendRequest.js'

export default function TopicForm({ minuteId }) {
  const [inputValue, setInputValue] = useState('')
  const isEmpty = inputValue === ''

  const handleInput = function (e) {
    setInputValue(e.target.value)
  }

  const handleClick = async function (e) {
    e.preventDefault()
    if (isEmpty) {
      return null
    }

    const parameter = { topic: { content: inputValue } }

    const response = await sendRequest(
      `/api/minutes/${minuteId}/topics`,
      'POST',
      parameter
    )

    if (response.status === 201) {
      setInputValue('')
    } else {
      const errorData = await response.json()
      console.error(errorData.errors.join(','))
    }
  }

  return (
    <ul>
      <li>
        <input
          type="text"
          value={inputValue}
          placeholder="Good First Issueをモブプロでやったらとても勉強になりました！"
          onChange={handleInput}
          id="new_topic_field"
          className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-600 focus:border-blue-500 inline-block p-2.5 w-[800px]"
        />
        <button
          type="button"
          onClick={handleClick}
          disabled={isEmpty}
          className="button mt-2 disabled:bg-slate-50 disabled:text-slate-500 disabled:border disabled:border-gray-300 disabled:hover:cursor-not-allowed"
        >
          作成
        </button>
      </li>
    </ul>
  )
}

TopicForm.propTypes = {
  minuteId: PropTypes.number,
}
