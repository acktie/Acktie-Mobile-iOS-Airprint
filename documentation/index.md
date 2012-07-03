# Acktie Mobile Airprint Module

## Description

This module allows for quick integration with Apple Airprint functionality.  It allow you to print from both local files or remote urls.

Additionally, this modules allows the mobile app to listen for user print events and user cancels dialog events.

## Accessing the Acktie Mobile Airprint Module

To access this module from JavaScript, you would do the following:

	var printer = require("com.acktie.mobile.ios.airprint");

The print variable is a reference to the Module object.	

## Reference

The following are the Javascript functions you can call with the module.

### print

Presents the user with the Apple Airprint dialog.  The user has the options to select the Airprint compatible print, number of pages to print, which pages to print,
or to cancel the dialog.

	printer.print({file: 'lorem.pdf'});

#### Properties
The following are the valid properties that can be passed into the print function.

##### file or url (required)
The following property is a required arguement for the print function to work.  This arguement tells the module which document to print and from which location.

file - a local file on the device. 

**NOTE**: file will only print documents from the application document directory.  If you are downloading the file from the internet some like: 

	var filename = Ti.Filesystem.applicationDataDirectory + remoteFilename;
	// Dummy method you need to write your own
	downloadFile(url, filename);

url - a remote url on the network

One of the arguments needs to be specified but not both.

##### displayPageRange (optional)
This property tells the print dialog whether or not to show the page range option.  The page range option is the option where the user can specify the pages to print from
a multi-page document.

Can be either true or false. 

##### jobName (optional)
This property give you the option to customize the job name displayed in the print manager.  If one is not given the filename (file.ext (e.g print.pdf)) is used.

##### view or navBarButton(Required for iPad)
This property specifies where to display the print dialog pop-up on an iPad.  These options are ignored on the iPhone so it is safe to specify it all the time for universal apps.

navBarButton must be a button assigned to the navigation bar.  If you want the print pop-up on a button in the middle of a view use the view option.

See app.js for examples.

#### Callbacks (optional)

*  sentToPrinter - Called in the event when the user a) clicks the print button, b) cancels the print action, or c) an error occurred with submitting the print job.  

##### Callback data

*  completed - The result will contain either true or false.  True if a print job was successfully sent to the print manager.  False if the user cancelled the print dialog or there was 
and error submitting to the print manager.
*  code - The error code (This comes from Apples API)
*  message - The error message (This comes from Apples API)

NOTE: The callback does not trigger when the document has printed only when the job was sent to the print manager.

Example: 

	function sentToPrinter(result){
		if(result.completed)
			alert("User submitted to printer");
		else
			alert("User cancelled print request");
	};


## Known issues
iPad - When changing the orientation the print dialog box does not re-display in the correct location (only if you use view option, works correctly for navbarbutton.).  NOTE: this does not effect print functionality.

Local file location - There is a limitation on where local files can be printed from.  Currently, the local file need to be in the documents directory
(Ti.Filesystem.applicationDataDirectory) under the application.  If you have documents packaged with your app you will need to move them to the documents
directory before printing.  This can be a 1 time action.

## Author

Tony Nuzzi @ Acktie

Twitter: @Acktie

Email: support@acktie.com
