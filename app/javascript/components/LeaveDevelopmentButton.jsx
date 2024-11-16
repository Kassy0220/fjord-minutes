import { useState } from 'react'
import { Modal, ModalBody } from 'flowbite-react'

export default function LeaveDevelopmentButton() {
  const [openModal, setOpenModal] = useState(false)
  const [selectedReason, setSelectedReason] = useState(null)

  const csrfToken = document.head.querySelector(
    'meta[name=csrf-token]'
  )?.content

  const handleSubmit = function (e) {
    e.preventDefault()
    const form = e.target
    form.submit()
  }

  return (
    <div>
      <button className="button open_modal" onClick={() => setOpenModal(true)}>
        チーム開発を抜ける
      </button>
      <Modal
        show={openModal}
        onClose={() => setOpenModal(false)}
        popup
        theme={customTheme}
      >
        <ModalBody>
          <div className="my-8 text-xl">
            <p className="text-center mb-4">
              チーム開発を抜ける理由を選択してください
            </p>
            <form
              action="/logout"
              method="POST"
              onSubmit={handleSubmit}
              className="inline-block"
            >
              <div className="text-left mb-2">
                <label className="block mb-2">
                  <input
                    type="radio"
                    id="completed"
                    name="reason"
                    value="completed"
                    className="mr-2"
                    checked={selectedReason === 'completed'}
                    onChange={(e) => setSelectedReason(e.target.value)}
                  />
                  チーム開発を修了したため
                </label>
                <label className="block mb-2">
                  <input
                    type="radio"
                    id="hibernated"
                    name="reason"
                    value="hibernated"
                    className="mr-2"
                    checked={selectedReason === 'hibernated'}
                    onChange={(e) => setSelectedReason(e.target.value)}
                  />
                  フィヨルドブートキャンプを休会することに伴い、チーム開発をお休みするため
                </label>
              </div>

              <input type="hidden" name="_method" value="DELETE" />
              <input
                type="hidden"
                name="authenticity_token"
                value={csrfToken}
                autoComplete="off"
              />
              <div className="text-center">
                <input
                  type="submit"
                  value="チーム開発を抜ける"
                  id="accept_modal"
                  className={
                    selectedReason === null ? 'button_disabled' : 'button'
                  }
                  disabled={selectedReason === null}
                />
                <button
                  type="button"
                  className="button_cancel"
                  onClick={() => setOpenModal(false)}
                >
                  キャンセル
                </button>
              </div>
            </form>
          </div>
        </ModalBody>
      </Modal>
    </div>
  )
}

const customTheme = {
  body: {
    popup: '', // デフォルトで設定してあるpt-0を削除
  },
}
