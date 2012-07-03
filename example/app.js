// Example of using Acktie Mobile Airprint

// Import
var printer = require("com.acktie.mobile.ios.airprint");

// open a single window
var window = Ti.UI.createWindow({
	backgroundColor : 'white'
});

var airprintFromLocalFile = Titanium.UI.createButton({
	title : 'Print from local file (canPrint?)' + printer.canPrint,
	height : 40,
	width : '100%',
	top : 5
});

airprintFromLocalFile.addEventListener('click', function() {
	printer.print({file: "lorem.pdf", 
				   displayPageRange: false,  // Turn of selectable page range
				   jobName: 'Custom JobName: lorem.pdf', // Give a custom job name.  By default, it will be the file name
				   view: airprintFromLocalFile});
});

window.add(airprintFromLocalFile);

var airprintFromUrl = Titanium.UI.createButton({
	title : 'Print from url (canPrint?)' + printer.canPrint,
	height : 40,
	width : '100%',
	top : 50
});
airprintFromUrl.addEventListener('click', function() {
	printer.print({url: 'http://adventurelearningschools.org/assets/files/Sample.pdf', 
				   view: airprintFromUrl,
				   sentToPrinter: function(result)  // Specify a callback to receive event when user prints or cancels the dialog
					{
						if(result.completed)
							alert("User submitted to printer");
						else
							alert("User cancelled print request");
					},
	});
});
window.add(airprintFromUrl);

var airprintWebPage = Titanium.UI.createButton({
	title : 'Print webpage from toImage',
	height : 40,
	width : '100%',
	top : 120
});
airprintWebPage.addEventListener('click', function() {
		var url = 'http://www.google.com';
		var win = Ti.UI.createWindow({
			fullscreen : true,
			title : 'Google',
			backgroundColor : 'white'
		});
		var webview = Ti.UI.createWebView({
			url : url
		});
		win.add(webview);
		self.containingTab.open(win);
		
		var rightbutton = Ti.UI.createButton({systemButton: Titanium.UI.iPhone.SystemButton.ACTION});
		win.rightNavButton = rightbutton;
		
		rightbutton.addEventListener('click', function() {
			var file = Titanium.Filesystem.getFile(Titanium.Filesystem.applicationDataDirectory, "printFile.jpg");
			file.write(webview.toImage());

			printer.print({
				file : 'printFile.jpg',
				keepScale: 'false', 
				navBarButton: rightbutton,
				sentToPrinter : function(result) // Specify a callback to receive event when user prints or cancels the dialog
				{
					if(result.completed)
						alert("User submitted to printer");
					else
						alert("User cancelled print request");
				},
			});
		});

});
window.add(airprintFromUrl);

window.open();