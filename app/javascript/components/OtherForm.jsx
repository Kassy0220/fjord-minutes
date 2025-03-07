import { useState, useCallback } from 'react'
import PropTypes from 'prop-types'
import sendRequest from '../sendRequest.js'
import useChannel from '../hooks/useChannel.js'
import { marked } from 'marked'
import DOMPurify from 'dompurify'

export default function OtherForm({ minuteId, content, isAdmin }) {
  const [otherContent, setOtherContent] = useState(content)

  const onReceivedData = useCallback(function (data) {
    if ('minute' in data.body) {
      setOtherContent(data.body.minute.other)
    }
  }, [])
  useChannel(minuteId, onReceivedData)

  return (
    <>
      {isAdmin ? (
        <EditForm minuteId={minuteId} content={otherContent} />
      ) : (
        <Other content={otherContent} />
      )}
    </>
  )
}

function EditForm({ minuteId, content }) {
  const [inputValue, setInputValue] = useState(content ?? '')

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
        placeholder="- RubyKaigiに参加するため、次回のミーティングは⚪︎月⚪︎日に行います"
        onChange={handleChange}
        id="other_field"
        className="block p-2.5 w-[800px] h-36 text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 "
      />
      <div>
        <button type="button" onClick={handleClick} className="button mt-2">
          更新
        </button>
      </div>
    </>
  )
}

function Other({ content }) {
  const sanitizedHTML = {
    __html: DOMPurify.sanitize(marked.parse(content, [{ gfm: true }])),
  }

  return <div dangerouslySetInnerHTML={sanitizedHTML} />
}

OtherForm.propTypes = {
  minuteId: PropTypes.number,
  content: PropTypes.string,
  isAdmin: PropTypes.bool,
}

EditForm.propTypes = {
  minuteId: PropTypes.number,
  content: PropTypes.string,
}

Other.propTypes = {
  content: PropTypes.string,
}
