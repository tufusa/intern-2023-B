// 巨大画像のアップロードを防止する
document.addEventListener("turbo:load", function() {
  document.addEventListener("change", function(event) {
    let image_upload = document.querySelector('#micropost_image');
    let image_files = image_upload.files;
    let value = 0;
    var file;
    console.log(image_files);
    for (var i = 0; i < image_files.length; i++)
    {
      file = image_files.item(i);
      value += file.size;
    }
    const size_in_megabytes = value/1024/1024;
    if (size_in_megabytes > 5) {
      alert("Maximum file size is 5MB. Please choose a smaller file.");
      image_upload.value = "";
    }

    let button = document.getElementById("able_post")
    if( image_files.length > 4 ){
      button.disabled = true;
    }
    else{
      button.disabled = false;
    }
  });
});
