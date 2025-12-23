import useSWR from 'swr'
import fetcher from '../fetcher.js'
import DOMPurify from 'dompurify'
import PropTypes from 'prop-types'

export default function Absentees({ meetingId, course_kind }) {
  const { data, error, isLoading } = useSWR(
    `/api/meetings/${meetingId}/attendances`,
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
          course_kind={course_kind}
        />
      ))}
    </ul>
  )
}

function Absentee({ absentee, course_kind }) {
  return (
    <li className="mb-4">
      <a href={`https://github.com/${absentee.name}`}>{`@${absentee.name}`}</a>
      <ul className="mt-2!">
        <li>
          欠席理由
          <ul>
            <li>{absentee.absence_reason}</li>
          </ul>
        </li>
        <li>
          今週の進捗
          <ul>
            {absentee.progress_report.split('\r\n').map((report, index) => (
              <li key={index}>
                <span
                  dangerouslySetInnerHTML={{
                    __html: DOMPurify.sanitize(
                      convertIssueNumberToLink(report, course_kind)
                    ),
                  }}
                ></span>
              </li>
            ))}
          </ul>
        </li>
      </ul>
    </li>
  )
}

function convertIssueNumberToLink(progress_report, course_kind) {
  const repositoryUrl =
    course_kind === 'back_end'
      ? 'https://github.com/fjordllc/bootcamp'
      : 'https://github.com/fjordllc/agent'

  return progress_report.replaceAll(
    /#(\d+)/g,
    `<a href="${repositoryUrl}/issues/$1" target="_blank">#$1</a>`
  )
}

Absentees.propTypes = {
  meetingId: PropTypes.number,
  course_kind: PropTypes.string,
}

Absentee.propTypes = {
  absentee: PropTypes.object,
  course_kind: PropTypes.string,
}
