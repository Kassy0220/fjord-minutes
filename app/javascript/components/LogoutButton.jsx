import { useState } from 'react'
import { Modal, ModalBody } from 'flowbite-react'

export default function LogoutButton() {
  const [openModal, setOpenModal] = useState(false)

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
          <div>
            <div className="my-8 text-xl">
              <p className="mb-4">
                どちらかのケースに当てはまる場合に、チーム開発を抜けてください。
              </p>
              <ul>
                <li>チーム開発を修了した。</li>
                <li>
                  フィヨルドブートキャンプを休会したことに伴い、チーム開発をお休みする。
                </li>
              </ul>
            </div>
            <div className="text-center">
              <SubmitForm />
              <button
                className="inline-block text-blue-600 hover:bg-blue-100 font-medium rounded-lg text-sm px-4 py-2 me-2 mb-2 ml-8 focus:outline-none border border-blue-600"
                onClick={() => setOpenModal(false)}
              >
                キャンセル
              </button>
            </div>
          </div>
        </ModalBody>
      </Modal>
    </div>
  )
}

function SubmitForm() {
  const csrfToken = document.head.querySelector(
    'meta[name=csrf-token]'
  )?.content

  const handleSubmit = function (e) {
    e.preventDefault()
    const form = e.target
    form.submit()
  }

  return (
    <form
      action="/logout"
      method="POST"
      onSubmit={handleSubmit}
      className="inline-block"
    >
      <input type="hidden" name="_method" value="DELETE" />
      <input
        type="hidden"
        name="authenticity_token"
        value={csrfToken}
        autoComplete="off"
      />
      <input
        type="submit"
        value="チーム開発を抜ける"
        id="accept_modal"
        className="button"
      />
    </form>
  )
}

const customTheme = {
  body: {
    popup: '', // デフォルトで設定してあるpt-0を削除
  },
}
