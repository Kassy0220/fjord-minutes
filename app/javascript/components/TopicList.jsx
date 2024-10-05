import { useState } from 'react'
import PropTypes from 'prop-types'

export default function TopicList({ minuteId, topics }) {
  return (
    <>
      <ul>
        {topics.map((topic) => (
          <li
            key={topic.id}
            className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle"
          >
            {topic.content}
          </li>
        ))}
      </ul>
      <CreateForm minuteId={minuteId} />
    </>
  )
}

function CreateForm({ minuteId }) {
  const [inputValue, setInputValue] = useState('')

  const handleInput = function (e) {
    setInputValue(e.target.value)
  }

  const handleClick = async function (e) {
    e.preventDefault()
    const parameter = { topic: { content: inputValue } }
    const csrfToken = document.head.querySelector(
      'meta[name=csrf-token]'
    )?.content

    const response = await fetch(`/api/minutes/${minuteId}/topics`, {
      method: 'POST',
      body: JSON.stringify(parameter),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-CSRF-Token': csrfToken,
      },
    })

    if (response.status === 201) {
      setInputValue('')
    } else {
      const errorData = await response.json()
      console.error(errorData.errors.join(','))
    }
  }

  return (
    <>
      <input
        type="text"
        value={inputValue}
        onChange={handleInput}
        className="w-[400px]"
      />
      <button
        type="button"
        onClick={handleClick}
        className="ml-2 py-1 px-2 border border-black"
      >
        作成
      </button>
    </>
  )
}

TopicList.propTypes = {
  minuteId: PropTypes.number,
  topics: PropTypes.array,
}

CreateForm.propTypes = {
  minuteId: PropTypes.number,
}
