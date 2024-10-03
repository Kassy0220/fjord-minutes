export default function ReleaseInformation({ minuteId, releaseBranch }) {
  return (
    <p>
      議事録({minuteId})のリリースブランチ: {releaseBranch}
    </p>
  )
}
