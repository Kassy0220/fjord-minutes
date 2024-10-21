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
    <li className="mb-4">
      <a
        href={`https://github.com/${absentee.name}`}
        className="text-sky-600 underline"
      >
        {`@${absentee.name}`}
      </a>
      {!isAdmin && currentMemberId === absentee.member_id && (
        <a
          href={`/attendances/${absentee.attendance_id}/edit`}
          className="ps-4 no-underline hover:!no-underline"
        >
          <span className="button">出席編集</span>
        </a>
      )}
      <ul className="!mt-2">
        <li>欠席理由: {absentee.absence_reason}</li>
        <li>今週の進捗: {absentee.progress_report}</li>
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
