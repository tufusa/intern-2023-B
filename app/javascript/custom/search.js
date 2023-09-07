document.addEventListener("turbo:load", () => {
  let form = document.getElementById('explore_microposts_form');
  let keywords = document.getElementById('keywords');

  keywords.addEventListener('change', (event) => {
    event.preventDefault();
    form.requestSubmit();
  });
});