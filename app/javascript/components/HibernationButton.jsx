import PropTypes from 'prop-types'
import { useState } from 'react'
import { Modal, ModalBody } from 'flowbite-react'

export default function HibernationButton({ member_id, member_name }) {
  const [openModal, setOpenModal] = useState(false)

  return (
    <div>
      <button
        id="open_modal"
        className="button_danger"
        onClick={() => setOpenModal(true)}
      >
        休止中にする
      </button>
      <Modal
        show={openModal}
        onClose={() => setOpenModal(false)}
        popup
        theme={customTheme}
      >
        <ModalBody>
          <div className="text-center">
            <p className="my-8 text-xl">
              {member_name}さんを休止中にします。よろしいですか？
            </p>
            <div>
              <SubmitForm memberId={member_id} />
              <button
                className="inline-block text-red-600 hover:bg-red-100 font-medium rounded-lg text-sm px-4 py-2 me-2 mb-2 ml-8 focus:outline-none border border-red-600"
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

function SubmitForm({ memberId }) {
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
      action={`/members/${memberId}/hibernations`}
      method="POST"
      onSubmit={handleSubmit}
      className="inline-block"
    >
      <input
        type="hidden"
        name="authenticity_token"
        value={csrfToken}
        autoComplete="off"
      />
      <input
        type="submit"
        value="休止中にする"
        id="accept_modal"
        className="button_danger"
      />
    </form>
  )
}

const customTheme = {
  body: {
    popup: '', // デフォルトで設定してあるpt-0を削除
  },
}

HibernationButton.propTypes = {
  member_id: PropTypes.number,
  member_name: PropTypes.string,
}

SubmitForm.propTypes = {
  memberId: PropTypes.number,
}
