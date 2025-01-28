import useSWR from 'swr'
import fetcher from '../fetcher.js'
import PropTypes from 'prop-types'

export default function AttendeesList({ minuteId, currentMemberId, isAdmin }) {
  const { data, error, isLoading } = useSWR(
    `/api/minutes/${minuteId}/attendances`,
    fetcher
  )

  if (error) return <p>エラーが発生しました</p>
  if (isLoading) return <p>読み込み中</p>

  return (
    <>
      <h3>昼の部</h3>
      <ul id="day_attendees">
        {data.day_attendees.map((attendee) => (
          <Attendee
            key={attendee.attendance_id}
            attendee={attendee}
            currentMemberId={currentMemberId}
            isAdmin={isAdmin}
          />
        ))}
      </ul>
      <h3>夜の部</h3>
      <ul id="night_attendees">
        {data.night_attendees.map((attendee) => (
          <Attendee
            key={attendee.attendance_id}
            attendee={attendee}
            currentMemberId={currentMemberId}
            isAdmin={isAdmin}
          />
        ))}
      </ul>
    </>
  )
}

function Attendee({ attendee, currentMemberId, isAdmin }) {
  return (
    <li key={attendee.attendance_id} className="mb-2">
      <a href={`https://github.com/${attendee.name}`}>{`@${attendee.name}`}</a>
      {!isAdmin && currentMemberId === attendee.member_id && (
        <a
          href={`/attendances/${attendee.attendance_id}/edit`}
          className="ps-4 no-underline hover:!no-underline"
        >
          <span className="button">出席編集</span>
        </a>
      )}
    </li>
  )
}

AttendeesList.propTypes = {
  minuteId: PropTypes.number,
  currentMemberId: PropTypes.number,
  isAdmin: PropTypes.bool,
}

Attendee.propTypes = {
  attendee: PropTypes.object,
  currentMemberId: PropTypes.number,
  isAdmin: PropTypes.bool,
}
