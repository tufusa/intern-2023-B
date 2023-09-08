// Micropost検索

document.addEventListener("turbo:load", () => {
  let form = document.getElementById('explore_microposts_form');
  let keywords = document.getElementById('keywords');
  let sort = document.getElementById('sort_by');

  const submit = (event) => {
    event.preventDefault();
    form.requestSubmit();
  }

  keywords.addEventListener('change', submit);
  sort.addEventListener('change', submit);
});