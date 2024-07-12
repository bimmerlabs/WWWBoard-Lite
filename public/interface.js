function myWarning(str) {
  var ok = confirm("Are you sure you want to delete this?  This cannot be undone!");
  if (ok == true) {
        window.location = str;
  }
}

function myWarning2(url, str) {
  var ok = confirm(str);
  if (ok == true) {
        window.location = url;
  }
}

function ToolbarCollapse() {
    var sidebar = document.getElementById('txtSidebar');
    var content = document.getElementById('txtContent');
    if (sidebar.style.display == 'none') {
        sidebar.style.display = 'block';
        sidebar.setAttribute('class', 'col-sm-3 sidenav');
	
    } else {
        sidebar.style.display = 'none';
        sidebar.setAttribute('class', 'col-sm-0 sidenav');
    }

    var content = document.getElementById('txtContent');
    var collapsebutton = document.getElementById('ToolbarCollapse');
    if (sidebar.style.display == 'none') {
        content.setAttribute('class', 'col-sm-12 text-left');
        collapsebutton.innerHTML = "tools +";
    } else {
       content.setAttribute('class', 'col-sm-9 text-left');
       collapsebutton.innerHTML = "tools -";
    }
}

function AddColumn() {
    var form = document.getElementById('AddColumn');
    if (form.style.display == 'none') {
        form.style.display = 'block';
    } 
    else {
        form.style.display = 'none';
    }
}

function RenameColumn(column) {
   var list = document.getElementById("RenameColumn");
   var hiddenname = document.getElementById("HiddenName");
   var newname = document.getElementById("NewName");
    if (list.style.display == 'none') {
        list.style.display = 'block';
        hiddenname.setAttribute("value", column);
        newname.setAttribute("value", column);
    } 
    else {
        list.style.display = 'none';
    }
}

function AddRow() {
    var form = document.getElementById('AddRow');
    var projects = document.getElementById('Projects');
    if (form.style.display == 'none') {
        form.style.display = 'block';
        projects.style.display = 'none';
    } 
    else {
        form.style.display = 'none';
        projects.style.display = 'block';
    }
}

function Upload(name, projectid, dme) {
   var list = document.getElementById('Upload');
   var projects = document.getElementById('Projects');
   var str = "Upload original binary for your project ";
    if (list.style.display == 'none') {
        list.style.display = 'block';
        projects.style.display = 'none';
        document.getElementById("HiddenProject").value = projectid;
        document.getElementById("HiddenDme").value = dme;
        document.getElementById("ProjectName").innerHTML  = str.concat(name);
    } 
    else {
        list.style.display = 'none';
        projects.style.display = 'block';
        document.getElementById("HiddenProject").value = "undefined";
        document.getElementById("HiddenDme").value = "undefined";
    }
}

function DisplayBlock(id) {
    var help = document.getElementById(id);
    var projects = document.getElementById('Projects');
    if (help.style.display == 'none') {
        help.style.display = 'block';
        projects.style.display = 'none';
    } 
    else {
        help.style.display = 'none';
        projects.style.display = 'block';
    }
}

function DisplayItem(id) {
    var item = document.getElementById(id);
    var buttonid = id.concat('button');
    var button = document.getElementById(buttonid);
    if (item.style.display == 'none') {
        item.style.display = '';
        button.setAttribute('class', 'glyphicon glyphicon-minus');
    } 
    else {
        item.style.display = 'none';
        button.setAttribute('class', 'glyphicon glyphicon-plus');
    }
}
