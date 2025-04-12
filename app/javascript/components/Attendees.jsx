import useSWR from 'swr'
import fetcher from '../fetcher.js'
import PropTypes from 'prop-types'

export default function Attendees({ meetingId }) {
  const { data, error, isLoading } = useSWR(
    `/api/meetings/${meetingId}/attendances`,
    fetcher
  )

  if (error) return <p>エラーが発生しました</p>
  if (isLoading) return <p>読み込み中</p>

  return (
    <>
      <h3>昼の部</h3>
      <ul id="afternoon_attendees">
        {data.afternoon_attendees.map((attendee) => (
          <Attendee key={attendee.attendance_id} attendee={attendee} />
        ))}
      </ul>
      <h3>夜の部</h3>
      <ul id="night_attendees">
        {data.night_attendees.map((attendee) => (
          <Attendee key={attendee.attendance_id} attendee={attendee} />
        ))}
      </ul>
    </>
  )
}

function Attendee({ attendee }) {
  return (
    <li key={attendee.attendance_id} className="mb-2">
      <a href={`https://github.com/${attendee.name}`}>{`@${attendee.name}`}</a>
    </li>
  )
}

Attendees.propTypes = {
  meetingId: PropTypes.number,
}

Attendee.propTypes = {
  attendee: PropTypes.object,
}
