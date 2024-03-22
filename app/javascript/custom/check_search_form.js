document.addEventListener('DOMContentLoaded', function() {
  const form = document.getElementById('user_search')
  const submit_button = document.getElementById('search_submit')

  function check_form() {
    const fieldValue = document.getElementById('q_name_cont').value.trim()

    if (fieldValue === '') {
      submit_button.disabled = true
    } else {
      submit_button.disabled = false
    }
  }

  form.addEventListener('input', check_form)

  check_form()
})
