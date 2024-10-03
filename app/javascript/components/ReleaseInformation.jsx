import PropTypes from 'prop-types'

export default function ReleaseInformation({ minuteId, releaseBranch }) {
  return (
    <p>
      議事録({minuteId})のリリースブランチ: {releaseBranch}
    </p>
  )
}

ReleaseInformation.propTypes = {
  minuteId: PropTypes.number,
  releaseBranch: PropTypes.string,
}
