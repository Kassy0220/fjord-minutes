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
    <ul>
      <li>
        プログラマー
        <ul>
          <li id="day_attendees">
            昼
            <ul>
              {data.day_attendees.map((attendee) => (
                <Attendee
                  key={attendee.attendance_id}
                  attendee={attendee}
                  currentMemberId={currentMemberId}
                  isAdmin={isAdmin}
                />
              ))}
            </ul>
          </li>
          <li id="night_attendees">
            夜
            <ul>
              {data.night_attendees.map((attendee) => (
                <Attendee
                  key={attendee.attendance_id}
                  attendee={attendee}
                  currentMemberId={currentMemberId}
                  isAdmin={isAdmin}
                />
              ))}
            </ul>
          </li>
        </ul>
      </li>
      <li>
        プロダクトオーナー
        <ul>
          <li>
            <a href="https://github.com/machida">@machida</a>
          </li>
        </ul>
      </li>
      <li>
        スクラムマスター
        <ul>
          <li>
            <a href="https://github.com/komagata">@komagata</a>
          </li>
        </ul>
      </li>
    </ul>
  )
}

function Attendee({ attendee, currentMemberId, isAdmin }) {
  return (
    <li key={attendee.attendance_id}>
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
