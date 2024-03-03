import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const mentorPractices = document.querySelector('#mentor-practices')
  if (mentorPractices) {
    const table = mentorPractices.querySelector('.admin-table__items')
    fetch(`/api/mentor/practices`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => response.json())
      .then((json) => {
        appendItem(json.practices, table)
      })
      .catch((error) => {
        console.warn(error)
      })
  }
});

function appendItem(practices, table){
  practices.forEach(practice => {
    table.innerHTML += `
      <tr class="admin-table__item">
        <td class="admin-table__item-value"><a href="/practices/${practice.id}">${practice.title}</a></td>
        <td class="admin-table__item-value is-text-align-right">${appendCategoryNames(practice)}</td>
        ${appendSubmissions(practice)}
        <td class="admin-table__item-value is-text-align-right"><a href="/practices/${practice.id}/reports">${practice.reports.size}</a></td>
        <td class="admin-table__item-value is-text-align-right"><a href="/practices/${practice.id}/questions">${practice.questions.size}</a></td>
        <td class="admin-table__item-value is-text-align-center">
          <ul class="is-inline-buttons">
            <li><a href="/mentor/practices/${practice.id}/edit" class="a-button is-sm is-secondary is-icon"><i class="fa-solid fa-pen" aria-hidden="true"></i></a></li>
          </ul>
        </td>
      </tr>
    `
  });
}

function appendCategoryNames(practice) {
  return practice.category_ids_names.map((categoryIdName) => 
    `<p>${categoryIdName.category_name}</p>`
  ).join('')
}

function appendSubmissions(practice) {
  const submissionsLink = `<td class="admin-table__item-value is-text-align-right"><a href="/practices/${practice.id}/products">${practice.products.size}</a></td>`
  const noSubmissions =  '<td class="admin-table__item-value is-text-align-center"><span class="admin-table__item-blank">不要</span></td>'
  return practice.submission ? submissionsLink : noSubmissions
}
