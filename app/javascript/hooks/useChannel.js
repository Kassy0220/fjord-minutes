import { useEffect } from 'react'
import consumer from '../channels/consumer.js'

export default function useChannel(minuteId, callback) {
  useEffect(() => {
    consumer.subscriptions.create(
      { channel: 'MinuteChannel', id: minuteId },
      {
        received(data) {
          callback(data)
        },
      }
    )

    return () => {
      // WebSocket接続を切断する : https://github.com/rails/rails/blob/f903206386a9e7d125c13dcdaa22be65680f428c/actioncable/app/javascript/action_cable/consumer.js#L19
      consumer.disconnect()
    }
  }, [minuteId, callback])
}
