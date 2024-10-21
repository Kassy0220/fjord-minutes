import { useState, useCallback } from 'react'
import PropTypes from 'prop-types'
import sendRequest from '../sendRequest.js'
import useChannel from '../hooks/useChannel.js'

export default function TopicList({
  minuteId,
  topics,
  currentDevelopmentMemberId,
  currentDevelopmentMemberType,
}) {
  const [allTopics, setAllTopics] = useState(topics)

  const onReceivedData = useCallback(function (data) {
    if ('topics' in data.body) {
      setAllTopics(data.body.topics)
    }
  }, [])
  useChannel(minuteId, onReceivedData)

  return (
    <>
      <ul>
        {allTopics.map((topic) => (
          <Topic
            key={topic.id}
            minuteId={minuteId}
            topic={topic}
            currentDevelopmentMemberId={currentDevelopmentMemberId}
            currentDevelopmentMemberType={currentDevelopmentMemberType}
          />
        ))}
      </ul>
      <CreateForm minuteId={minuteId} />
    </>
  )
}

function Topic({
  minuteId,
  topic,
  currentDevelopmentMemberId,
  currentDevelopmentMemberType,
}) {
  const [isEditing, setIsEditing] = useState(false)

  const handleDelete = async function (e) {
    e.preventDefault()

    const response = await sendRequest(
      `/api/minutes/${minuteId}/topics/${topic.id}`,
      'DELETE',
      {}
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
        <li>
          <span>
            {topic.content}({topic.topicable.name})
          </span>
          {isMine(
            topic.topicable_id,
            topic.topicable_type,
            currentDevelopmentMemberId,
            currentDevelopmentMemberType
          ) && (
            <>
              <button
                type="button"
                onClick={() => setIsEditing(true)}
                className="button"
              >
                編集
              </button>
              <button
                type="button"
                onClick={handleDelete}
                className="button_danger"
              >
                削除
              </button>
            </>
          )}
        </li>
      )}
    </>
  )
}

function isMine(topicableId, topicableType, memberId, memberType) {
  return topicableId === memberId && topicableType === memberType
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

    const response = await sendRequest(
      `/api/minutes/${minuteId}/topics/${topicId}`,
      'PATCH',
      parameter
    )

    if (response.status === 200) {
      setIsEditing(false)
    } else {
      const errorData = await response.json()
      console.error(errorData.errors.join(','))
    }
  }

  return (
    <li>
      <input
        type="text"
        value={inputValue}
        onChange={handleInput}
        className="input_type_text max-w-[800px]"
      />
      <button
        type="button"
        onClick={handleClick}
        disabled={isEmpty}
        className="button disabled:bg-slate-50 disabled:text-slate-500 disabled:border disabled:border-gray-300 disabled:hover:cursor-not-allowed"
      >
        更新
      </button>
    </li>
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
    <>
      <input
        type="text"
        value={inputValue}
        onChange={handleInput}
        className="input_type_text"
      />
      <button
        type="button"
        onClick={handleClick}
        disabled={isEmpty}
        className="button disabled:bg-slate-50 disabled:text-slate-500 disabled:border disabled:border-gray-300 disabled:hover:cursor-not-allowed"
      >
        作成
      </button>
    </>
  )
}

TopicList.propTypes = {
  minuteId: PropTypes.number,
  topics: PropTypes.array,
  currentDevelopmentMemberId: PropTypes.number,
  currentDevelopmentMemberType: PropTypes.string,
}

Topic.propTypes = {
  minuteId: PropTypes.number,
  topic: PropTypes.object,
  currentDevelopmentMemberId: PropTypes.number,
  currentDevelopmentMemberType: PropTypes.string,
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
