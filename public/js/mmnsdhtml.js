var MMNSDisplay = function() {

  // スクロールバーを含まない横幅を返す
  this.width = function() {
    // Firefox
    if (document.documentElement.clientWidth) {
      return(document.documentElement.clientWidth);
    }
  }

  // スクロールバーを含まない縦幅を返す
  this.height = function() {
    // Firefox
    if (document.documentElement.clientHeight) {
      return(document.documentElement.clientHeight);
    }
  }
}

