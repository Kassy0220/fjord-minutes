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
      <li className="pl-8">
        プログラマー
        <ul>
          <li className="pl-8">
            昼
            <Attendees
              attendees={data.day_attendees}
              currentMemberId={currentMemberId}
              isAdmin={isAdmin}
            />
          </li>
          <li className="pl-8">
            夜
            <Attendees
              attendees={data.night_attendees}
              currentMemberId={currentMemberId}
              isAdmin={isAdmin}
            />
          </li>
        </ul>
      </li>
      <li className="pl-8">
        プロダクトオーナー
        <ul>
          <li className="pl-8">
            <a
              href="https://github.com/machida"
              className="text-sky-600 underline"
            >
              @machida
            </a>
          </li>
        </ul>
      </li>
      <li className="pl-8">
        スクラムマスター
        <ul>
          <li className="pl-8">
            <a
              href="https://github.com/komagata"
              className="text-sky-600 underline"
            >
              @komagata
            </a>
          </li>
        </ul>
      </li>
    </ul>
  )
}

function Attendees({ attendees, currentMemberId, isAdmin }) {
  return (
    <ul>
      {attendees.map((attendee) => (
        <li key={attendee.attendance_id} className="pl-8">
          <a
            href={`https://github.com/${attendee.name}`}
            className="text-sky-600 underline"
          >{`@${attendee.name}`}</a>
          {!isAdmin && currentMemberId === attendee.member_id && (
            <a
              href={`/attendances/${attendee.attendance_id}/edit`}
              className="inline-block ml-2 py-1 px-2 border border-black"
            >
              出席編集
            </a>
          )}
        </li>
      ))}
    </ul>
  )
}

AttendeesList.propTypes = {
  minuteId: PropTypes.number,
  currentMemberId: PropTypes.number,
  isAdmin: PropTypes.bool,
}

Attendees.propTypes = {
  attendees: PropTypes.array,
  currentMemberId: PropTypes.number,
  isAdmin: PropTypes.bool,
}
