import { useState } from 'react'
import PropTypes from 'prop-types'

export default function TopicList({ minuteId, topics }) {
  return (
    <>
      <ul>
        {topics.map((topic) => (
          <Topic key={topic.id} minuteId={minuteId} topic={topic} />
        ))}
      </ul>
      <CreateForm minuteId={minuteId} />
    </>
  )
}

function Topic({ minuteId, topic }) {
  const [isEditing, setIsEditing] = useState(false)

  const handleDelete = async function (e) {
    e.preventDefault()
    const csrfToken = document.head.querySelector(
      'meta[name=csrf-token]'
    )?.content

    const response = await fetch(
      `/api/minutes/${minuteId}/topics/${topic.id}`,
      {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-CSRF-Token': csrfToken,
        },
      }
    )

    if (response.status !== 204) {
      const errorData = await response.json()
      console.error(errorData.errors.join(','))
    }
  }

  return (
    <>
      {isEditing ? (
        <EditForm
          minuteId={minuteId}
          topicId={topic.id}
          content={topic.content}
          setIsEditing={setIsEditing}
        />
      ) : (
        <li className="pl-8 mb-2 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle">
          <span>{topic.content}</span>
          <button
            type="button"
            onClick={() => setIsEditing(true)}
            className="ml-2 py-1 px-2 border border-black"
          >
            編集
          </button>
          <button
            type="button"
            onClick={handleDelete}
            className="ml-2 py-1 px-2 border border-black"
          >
            削除
          </button>
        </li>
      )}
    </>
  )
}

function EditForm({ minuteId, topicId, content, setIsEditing }) {
  const [inputValue, setInputValue] = useState(content)
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
    const csrfToken = document.head.querySelector(
      'meta[name=csrf-token]'
    )?.content

    const response = await fetch(`/api/minutes/${minuteId}/topics/${topicId}`, {
      method: 'PATCH',
      body: JSON.stringify(parameter),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-CSRF-Token': csrfToken,
      },
    })

    if (response.status === 200) {
      setIsEditing(false)
    } else {
      const errorData = await response.json()
      console.error(errorData.errors.join(','))
    }
  }

  return (
    <div className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
      <input
        type="text"
        value={inputValue}
        onChange={handleInput}
        className="field-sizing-content max-w-[600px]"
      />
      <button
        type="button"
        onClick={handleClick}
        disabled={isEmpty}
        className="ml-2 py-1 px-2 border border-black disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200"
      >
        更新
      </button>
    </div>
  )
}

function CreateForm({ minuteId }) {
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
        disabled={isEmpty}
        className="ml-2 py-1 px-2 border border-black disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200"
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

Topic.propTypes = {
  minuteId: PropTypes.number,
  topic: PropTypes.object,
}

EditForm.propTypes = {
  minuteId: PropTypes.number,
  topicId: PropTypes.number,
  content: PropTypes.string,
  setIsEditing: PropTypes.func,
}

CreateForm.propTypes = {
  minuteId: PropTypes.number,
}
