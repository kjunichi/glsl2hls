const apiUrl = "/glsl";

function makeJson(vs, fs) {
  j = {
    v: vs,
    f: fs
  };

  return j;
}
const btn = document.getElementById("btnRun");
btn.addEventListener("click", () => {
  json = makeJson(
    document.getElementById("vshader").value,
    document.getElementById("fshader").value);
  const xhr = new XMLHttpRequest();
  xhr.onload =  ()=> {
    console.log("xhr start");
    const resJson = JSON.parse(xhr.responseText);
    const videoId = resJson.Id;
    const out = document.getElementById("out");
    setTimeout(function () {
      out.src = videoId + ".m3u8";
      out.addEventListener('dataloaded', function () {
        out.play();
      }, false);
    }, 8000);
  };
  xhr.open('POST', apiUrl, true);
  xhr.setRequestHeader("Content-type", "application/json");
  //console.log(json);
  xhr.send(JSON.stringify(json));

}, false);
