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
