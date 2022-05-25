# Powershell script to export Powerpoint Presentations to pdf using the Powerpoint COM API
# Based on a VB script with the same purpose
# http://superuser.com/questions/641471/how-can-i-automatically-convert-powerpoint-to-pdf


function Export-Presentation($inputFile)
{
	# Load Powerpoint Interop Assembly
	[Reflection.Assembly]::LoadWithPartialname("Microsoft.Office.Interop.Powerpoint") > $null
	[Reflection.Assembly]::LoadWithPartialname("Office") > $null

	$msoFalse =  [Microsoft.Office.Core.MsoTristate]::msoFalse
	$msoTrue =  [Microsoft.Office.Core.MsoTristate]::msoTrue

	$ppFixedFormatIntentScreen = [Microsoft.Office.Interop.PowerPoint.PpFixedFormatIntent]::ppFixedFormatIntentScreen # Intent is to view exported file on screen.
	$ppFixedFormatIntentPrint =  [Microsoft.Office.Interop.PowerPoint.PpFixedFormatIntent]::ppFixedFormatIntentPrint  # Intent is to print exported file.

	$ppFixedFormatTypeXPS = [Microsoft.Office.Interop.PowerPoint.PpFixedFormatType]::ppFixedFormatTypeXPS  # XPS format
	$ppFixedFormatTypePDF = [Microsoft.Office.Interop.PowerPoint.PpFixedFormatType]::ppFixedFormatTypePDF  # PDF format

	$ppPrintHandoutVerticalFirst = 1   # Slides are ordered vertically, with the first slide in the upper-left corner and the second slide below it.
	$ppPrintHandoutHorizontalFirst = 2 # Slides are ordered horizontally, with the first slide in the upper-left corner and the second slide to the right of it.

	$ppPrintOutputSlides = 1               # Slides
	$ppPrintOutputTwoSlideHandouts = 2     # Two Slide Handouts
	$ppPrintOutputThreeSlideHandouts = 3   # Three Slide Handouts
	$ppPrintOutputSixSlideHandouts = 4     # Six Slide Handouts
	$ppPrintOutputNotesPages = 5           # Notes Pages
	$ppPrintOutputOutline = 6              # Outline
	$ppPrintOutputBuildSlides = 7          # Build Slides
	$ppPrintOutputFourSlideHandouts = 8    # Four Slide Handouts
	$ppPrintOutputNineSlideHandouts = 9    # Nine Slide Handouts
	$ppPrintOutputOneSlideHandouts = 10    # Single Slide Handouts

	$ppPrintAll = 1            # Print all slides in the presentation.
	$ppPrintSelection = 2      # Print a selection of slides.
	$ppPrintCurrent = 3        # Print the current slide from the presentation.
	$ppPrintSlideRange = 4     # Print a range of slides.
	$ppPrintNamedSlideShow = 5 # Print a named slideshow.

	$ppShowAll = 1             # Show all.
	$ppShowNamedSlideShow = 3  # Show named slideshow.
	$ppShowSlideRange = 2      # Show slide range.

	
	# start Powerpoint
	$application = New-Object "Microsoft.Office.Interop.Powerpoint.ApplicationClass" 

	# Make sure inputFile is an absolte path
	$inputFile = Resolve-Path $inputFile
	$outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".pdf")
	
	$application.Visible = $msoTrue
	$presentation = $application.Presentations.Open($inputFile, $msoTrue, $msoFalse, $msoFalse)
	$printOptions = $presentation.PrintOptions
	$range = $printOptions.Ranges.Add(1,$presentation.Slides.Count) 
	$printOptions.RangeType = $ppShowAll
	
	# export presentation to pdf
	$presentation.ExportAsFixedFormat($outputFile, $ppFixedFormatTypePDF, $ppFixedFormatIntentScreen, $msoTrue, $ppPrintHandoutHorizontalFirst, $ppPrintOutputSlides, $msoFalse, $range, $ppPrintAll, "Slideshow Name", $False, $False, $False, $False, $False)
	
	$presentation.Close()
	$presentation = $null
	
	if($application.Windows.Count -eq 0)
	{
		$application.Quit()
	}
	
	$application = $null
	
	# Make sure references to COM objects are released, otherwise powerpoint might not close
	# (calling the methods twice is intentional, see https://msdn.microsoft.com/en-us/library/aa679807(office.11).aspx#officeinteroperabilitych2_part2_gc)
	[System.GC]::Collect();
	[System.GC]::WaitForPendingFinalizers();
	[System.GC]::Collect();
	[System.GC]::WaitForPendingFinalizers();

}