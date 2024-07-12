function myWarning(str) {
  var ok = confirm("Are you sure you want to delete your project?  This cannot be undone!");
  if (ok == true) {
        window.location = str;
  }
}

function ToolbarCollapse() {
    var sidebar = document.getElementById('txtSidebar');
    var content = document.getElementById('txtContent');
    if (sidebar.style.display === 'none') {
        sidebar.style.display = 'block';
        sidebar.setAttribute('class', 'col-sm-3 sidenav');
	
    } else {
        sidebar.style.display = 'none';
        sidebar.setAttribute('class', 'col-sm-0 sidenav');
    }

    var content = document.getElementById('txtContent');
    var collapsebutton = document.getElementById('ToolbarCollapse');
    if (sidebar.style.display === 'none') {
        content.setAttribute('class', 'col-sm-12 text-left');
        collapsebutton.innerHTML = "Project Selection +";
    } else {
       content.setAttribute('class', 'col-sm-9 text-left');
       collapsebutton.innerHTML = "Project Selection -";
    }
}

function showProject(str) {
  var xhttp;    
  if (str == "") {
    document.getElementById("txtContent").innerHTML = "";
    return;
  }
  document.getElementById("txtContent").innerHTML = "Loading....";
  xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById("txtContent").innerHTML = this.responseText;
    }
  };
  xhttp.open("GET", "http://cpu2344:3000/T/"+str, true);
  xhttp.send();
}

  function showParam(str) {
  var xhttp;    
  xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById("txtContent").innerHTML = this.responseText;
    }
  };
  xhttp.open("GET", "http://cpu2344:3000/"+str, true);
  xhttp.send();
}

function loadDoc(url, cFunction) {
  var xhttp;    
  xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      cFunction(this);
    }
  };
  xhttp.open("GET", url, true);
  xhttp.send();
}

function txtContent(xhttp) {
  document.getElementById("txtContent").innerHTML =
  xhttp.responseText;
}