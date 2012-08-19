var printer = require("com.acktie.mobile.ios.airprint");

var plainText = "This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. \n This is sample data for a text file \n This is sample data for a text file \n This is sample data for a text file \n This is sample data for a text file \n";
var markupText = "<h1>Sample Text</h1><br/>This is <i>sample</i> data for a text file. <p>This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file. This is sample data for a text file.</p><img border=\"0\" src=\"https://app-direct-www-cloudfront.s3.amazonaws.com/app_resources/2648/thumbs_64/img5786968329042998192.png\" />";
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
	top : 100
});
airprintWebPage.addEventListener('click', function() {
		var url = 'http://www.google.com';
		var win = Ti.UI.createWindow({
			modal:true,
   			modalStyle: Ti.UI.iPhone.MODAL_PRESENTATION_FORMSHEET,
			title : 'Google',
			backgroundColor : 'white'
		});
		var webview = Ti.UI.createWebView({
			url : url
		});
		win.add(webview);
		
		var rightbutton = Ti.UI.createButton({systemButton: Titanium.UI.iPhone.SystemButton.ACTION});
		win.rightNavButton = rightbutton;
		
		// Disable button until webview is loaded
		rightbutton.enabled = false;
		
		var leftbutton = Ti.UI.createButton({systemButton: Titanium.UI.iPhone.SystemButton.CANCEL});
		win.leftNavButton = leftbutton;
		
		win.open()
		webview.addEventListener('load', function()
		{
			// Show button after the web view has loaded the webpage
			rightbutton.enabled = true;
		});
		leftbutton.addEventListener('click', function() {win.close()});
		rightbutton.addEventListener('click', function() {
			var file = Titanium.Filesystem.getFile(Titanium.Filesystem.applicationDataDirectory, "printFile.png");
			file.write(webview.toImage());

			printer.print({
				file : 'printFile.png',
				keepScale: true,  // for images only
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
window.add(airprintWebPage);

var airprintTextFile = Titanium.UI.createButton({
	title : 'Print text file from local (landscape)',
	height : 40,
	width : '100%',
	top : 150
});
airprintTextFile.addEventListener('click', function() {
	var filename = "textfile.txt";
	var fullFilename = Titanium.Filesystem.applicationDataDirectory + filename;
	var file = Titanium.Filesystem.getFile(Titanium.Filesystem.applicationDataDirectory, filename);
	
	if(file.exists())
	{
		file.deleteFile();
	}
	
	if(file.write(plainText))
	{
		if(file.exists())
		{
			Ti.API.info("Can Print: " + printer.canPrint);
			printer.print({
				text: {
					isMarkup: false,
					textAlign: 'center', // Default is left
					fontSize: 18.0       // default is 12.0
				},
				file : filename,
				orientation: 'landscape',
				view: airprintTextFile,
				sentToPrinter : function(result) // Specify a callback to receive event when user prints or cancels the dialog
				{
					if(result.completed)
						alert("User submitted to printer");
					else
						alert("User cancelled print request");
				},
			});
		}
	}
});
window.add(airprintTextFile);

var airprintMarkupFile = Titanium.UI.createButton({
	title : 'Print Markup text file from local directory',
	height : 40,
	width : '100%',
	top : 200
});
airprintMarkupFile.addEventListener('click', function() {
	var filename = "markupfile.txt";
	var fullFilename = Titanium.Filesystem.applicationDataDirectory + filename;
	var file = Titanium.Filesystem.getFile(Titanium.Filesystem.applicationDataDirectory, filename);
	
	if(file.exists())
	{
		file.deleteFile();
	}
	
	if(file.write(markupText))
	{
		if(file.exists())
		{
			Ti.API.info("Can Print: " + printer.canPrint);
			printer.print({
				text: {
					isMarkup: true,
					// NOTE: textAlign and fontSize is ignored when isMarkup is true.
				},
				file : filename,
				view: airprintMarkupFile,
				sentToPrinter : function(result) // Specify a callback to receive event when user prints or cancels the dialog
				{
					if(result.completed)
						alert("User submitted to printer");
					else
						alert("User cancelled print request");
				},
			});
		}
	}
});
window.add(airprintMarkupFile);

window.open();
