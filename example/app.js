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

window.open();