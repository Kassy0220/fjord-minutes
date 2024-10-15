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
      <li className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle">
        プログラマー
        <ul>
          <li className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
            昼
            <Attendees
              attendees={data.day_attendees}
              currentMemberId={currentMemberId}
              isAdmin={isAdmin}
            />
          </li>
          <li className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
            夜
            <Attendees
              attendees={data.night_attendees}
              currentMemberId={currentMemberId}
              isAdmin={isAdmin}
            />
          </li>
        </ul>
      </li>
      <li className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle">
        プロダクトオーナー
        <ul>
          <li className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
            <a
              href="https://github.com/machida"
              className="text-sky-600 underline"
            >
              @machida
            </a>
          </li>
        </ul>
      </li>
      <li className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle">
        スクラムマスター
        <ul>
          <li className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
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
        <li
          key={attendee.attendance_id}
          className="relative before:absolute before:left-8 before:top-1/2 before:w-1.5 before:h-1.5 before:bg-black before:rounded-sm before:transform before:-translate-y-1/2 before:mr-2 pl-12"
        >
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
