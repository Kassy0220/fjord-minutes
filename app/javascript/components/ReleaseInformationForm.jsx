import { useState, useCallback } from 'react'
import PropTypes from 'prop-types'
import sendRequest from '../sendRequest.js'
import useChannel from '../hooks/useChannel.js'

export default function ReleaseInformationForm({
  minuteId,
  description,
  content,
  isAdmin,
}) {
  const [informationContent, setInformationContent] = useState(content)
  const [isEditing, setIsEditing] = useState(false)

  const onReceivedData = useCallback(
    function (data) {
      if ('minute' in data.body) {
        const key = `release_${description}`
        setInformationContent(data.body.minute[key])
      }
    },
    [description]
  )
  useChannel(minuteId, onReceivedData)

  const label = description === 'branch' ? 'リリースブランチ' : 'リリースノート'

  return (
    <ul>
      <li>
        <span>{label}</span>
        <ul>
          {isEditing ? (
            <EditForm
              minuteId={minuteId}
              description={description}
              content={informationContent}
              setIsEditing={setIsEditing}
            />
          ) : (
            <ReleaseInformation
              content={informationContent}
              setIsEditing={setIsEditing}
              isAdmin={isAdmin}
            />
          )}
        </ul>
      </li>
    </ul>
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
        ? { minute: { release_branch: inputValue } }
        : { minute: { release_note: inputValue } }

    const response = await sendRequest(
      `/api/minutes/${minuteId}`,
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
        id={`release_${description}_field`}
        className="input_type_text"
      />
      <button type="button" onClick={handleClick} className="button">
        更新
      </button>
    </li>
  )
}

function ReleaseInformation({ content, setIsEditing, isAdmin }) {
  return (
    <li>
      <span>{content}</span>
      {isAdmin && (
        <button
          type="button"
          onClick={() => setIsEditing(true)}
          className="button"
        >
          編集
        </button>
      )}
    </li>
  )
}

ReleaseInformationForm.propTypes = {
  minuteId: PropTypes.number,
  description: PropTypes.string,
  content: PropTypes.string,
  isAdmin: PropTypes.bool,
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
  isAdmin: PropTypes.bool,
}
