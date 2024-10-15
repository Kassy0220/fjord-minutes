import useSWR from 'swr'
import fetcher from '../fetcher.js'
import PropTypes from 'prop-types'

export default function AbsenteesList({ minuteId, currentMemberId, isAdmin }) {
  const { data, error, isLoading } = useSWR(
    `/api/minutes/${minuteId}/attendances`,
    fetcher
  )

  if (error) return <p>エラーが発生しました</p>
  if (isLoading) return <p>読み込み中</p>

  return (
    <ul>
      {data.absentees.map((absentee) => (
        <Absentee
          key={absentee.attendance_id}
          absentee={absentee}
          currentMemberId={currentMemberId}
          isAdmin={isAdmin}
        />
      ))}
    </ul>
  )
}

function Absentee({ absentee, currentMemberId, isAdmin }) {
  return (
    <li>
      <a
        href={`https://github.com/${absentee.name}`}
        className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle text-sky-600 underline"
      >
        {`@${absentee.name}`}
      </a>
      {!isAdmin && currentMemberId === absentee.member_id && (
        <a
          href={`/attendances/${absentee.attendance_id}/edit`}
          className="inline-block ml-2 py-1 px-2 border border-black"
        >
          出席編集
        </a>
      )}
      <ul>
        <li className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
          欠席理由: {absentee.absence_reason}
        </li>
        <li className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
          今週の進捗: {absentee.progress_report}
        </li>
      </ul>
    </li>
  )
}

AbsenteesList.propTypes = {
  minuteId: PropTypes.number,
  currentMemberId: PropTypes.number,
  isAdmin: PropTypes.bool,
}

Absentee.propTypes = {
  absentee: PropTypes.object,
  currentMemberId: PropTypes.number,
  isAdmin: PropTypes.bool,
}
