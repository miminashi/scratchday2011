(function(){
  var display = new MMNSDisplay();
  console.log('width = ' + display.width());
  console.log('height = ' + display.height());

  function initializeSocket() {
    ws = new WebSocket('ws://' + host + ':' + port);
    ws.onopen = function(e) {
      console.log('onopen');
    };
    ws.onclose = function(e) {
      console.log('onclose');
      setTimeout(initializeSocket(), 2000);
    };
    ws.onmessage = function(e) {
      console.log('onmessage');
      var obj = eval('(' + e.data + ')');
      if(obj['scratch_project']) {
        console.log(obj['scratch_project']);
        var scratch_project = obj['scratch_project'];
        changeScratch(scratch_project['owner'], scratch_project['id']);
      }
      var id = 'status_' + obj['id'];
      var innerHTML = '<div class="status" id="' + id + '">';
      innerHTML += '<img class="profile_image" src="' + obj['profile_image_url'] + '" alt="hoge" />';
      innerHTML += '<p class="text">' + obj['text'] + '</p>';
      innerHTML += '</div>';
      $('#twitter').append(innerHTML);
      $('#' + id).css('left', Math.floor(Math.random() * (display.width() - $('#' + id).width())));
      $('#' + id).animate({top: display.height()}, 16000, 'linear', function() {
        $('#' + id).remove();
      });
    };
    ws.onerror = function(e) {
      console.log('onerror');
    }; 
  }

  function changeScratch(owner, id) {
    console.log('changeScratch()');
    var innerHTML = '<applet id="ProjectApplet" style="display:block" code="ScratchApplet" codebase="http://scratch.mit.edu/static/misc" archive="ScratchApplet.jar" height="387" width="482">';
    innerHTML += '<param name="project" value="../../static/projects/' + owner + '/' + id + '.sb">';
    innerHTML += '</applet>';
    $('#scratch applet').replaceWith(innerHTML);
  }

  initializeSocket();
})();

