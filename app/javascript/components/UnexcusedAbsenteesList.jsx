import useSWR from 'swr'
import fetcher from '../fetcher.js'
import PropTypes from 'prop-types'

export default function UnexcusedAbsenteesList({
  minuteId,
  currentMemberId,
  isAdmin,
}) {
  const { data, error, isLoading } = useSWR(
    `/api/minutes/${minuteId}/attendances`,
    fetcher
  )

  if (error) return <p>エラーが発生しました</p>
  if (isLoading) return <p>読み込み中</p>

  return (
    <ul>
      {data.unexcused_absentees.map((absentee) => (
        <li key={absentee.member_id} className="pl-8">
          <a
            href={`https://github.com/${absentee.name}`}
            className="text-sky-600 underline"
          >{`@${absentee.name}`}</a>
          {!isAdmin && currentMemberId === absentee.member_id && (
            <a
              href={`/minutes/${minuteId}/attendances/new`}
              className="inline-block ml-2 py-1 px-2 border border-black"
            >
              出席登録
            </a>
          )}
        </li>
      ))}
    </ul>
  )
}

UnexcusedAbsenteesList.propTypes = {
  minuteId: PropTypes.number,
  currentMemberId: PropTypes.number,
  isAdmin: PropTypes.bool,
}
