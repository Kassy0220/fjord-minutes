import { useState } from 'react'
import PropTypes from 'prop-types'

export default function ReleaseInformationForm({
  minuteId,
  description,
  content,
}) {
  const [isEditing, setIsEditing] = useState(false)
  const label = description === 'branch' ? 'リリースブランチ' : 'リリースノート'

  return (
    <>
      <div className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle">
        <span>{label}</span>
      </div>
      {isEditing ? (
        <EditForm
          minuteId={minuteId}
          description={description}
          content={content}
          setIsEditing={setIsEditing}
        />
      ) : (
        <ReleaseInformation content={content} setIsEditing={setIsEditing} />
      )}
    </>
  )
}

function EditForm({ minuteId, description, content, setIsEditing }) {
  const [inputValue, setInputValue] = useState(content)
  const handleInput = function (e) {
    setInputValue(e.target.value)
  }

  const handleClick = async function (e) {
    e.preventDefault()
    const parameter =
      description === 'branch'
        ? { release_branch: inputValue }
        : { release_note: inputValue }
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

    if (response.status === 200) {
      setIsEditing(false)
    } else {
      console.log(response.statusText)
    }
  }

  return (
    <div className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
      <input
        type="text"
        value={inputValue}
        onChange={handleInput}
        className="w-96"
      />
      <button
        type="button"
        onClick={handleClick}
        className="ml-2 py-1 px-2 border border-black"
      >
        更新
      </button>
    </div>
  )
}

function ReleaseInformation({ content, setIsEditing }) {
  return (
    <>
      <div className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
        <span>{content}</span>
        <button
          type="button"
          onClick={() => setIsEditing(true)}
          className="ml-2 py-1 px-2 border border-black"
        >
          編集
        </button>
      </div>
    </>
  )
}

ReleaseInformationForm.propTypes = {
  minuteId: PropTypes.number,
  description: PropTypes.string,
  content: PropTypes.string,
}

EditForm.propTypes = {
  minuteId: PropTypes.number,
  description: PropTypes.string,
  content: PropTypes.string,
  setIsEditing: PropTypes.func,
}

ReleaseInformation.propTypes = {
  content: PropTypes.string,
  setIsEditing: PropTypes.func,
}
