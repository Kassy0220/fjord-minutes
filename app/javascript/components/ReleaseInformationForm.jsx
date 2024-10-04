import { useState } from 'react'
import PropTypes from 'prop-types'

export default function ReleaseInformationForm({ minuteId, releaseBranch }) {
  const [isEditing, setIsEditing] = useState(false)

  return isEditing ? (
    <EditForm
      minuteId={minuteId}
      releaseBranch={releaseBranch}
      setIsEditing={setIsEditing}
    />
  ) : (
    <ReleaseInformation
      releaseBranch={releaseBranch}
      setIsEditing={setIsEditing}
    />
  )
}

function EditForm({ minuteId, releaseBranch, setIsEditing }) {
  const [inputValue, setInputValue] = useState(releaseBranch)
  const handleInput = function (e) {
    setInputValue(e.target.value)
  }

  const handleClick = async function (e) {
    e.preventDefault()
    const parameter = { release_branch: inputValue }
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
    <>
      <input type="text" value={inputValue} onChange={handleInput} />
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

function ReleaseInformation({ releaseBranch, setIsEditing }) {
  return (
    <>
      <div className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle">
        <span>リリースブランチ</span>
      </div>
      <div className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
        <span>{releaseBranch}</span>
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
  releaseBranch: PropTypes.string,
}

EditForm.propTypes = {
  minuteId: PropTypes.number,
  releaseBranch: PropTypes.string,
  setIsEditing: PropTypes.func,
}

ReleaseInformation.propTypes = {
  releaseBranch: PropTypes.string,
  setIsEditing: PropTypes.func,
}
