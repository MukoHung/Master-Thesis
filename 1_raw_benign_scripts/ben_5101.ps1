#Copyright (c) 2014,2022 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# http://www.java2s.com/Code/CSharpAPI/System.Windows.Forms/TabControlControlsAdd.htm
# with sizes adjusted to run the focus demo
# see also:
# https://stackoverflow.com/questions/17926197/open-local-file-in-system-windows-forms-webbrowser-control
# http://www.java2s.com/Tutorial/CSharp/0460__GUI-Windows-Forms/AsimpleBrowser.htm
# https://www.c-sharpcorner.com/UploadFile/mahesh/webbrowser-control-in-C-Sharp-and-windows-forms/
param (
  [string]$filename
)
Add-Type -TypeDefinition @'

using System;
using System.Text;
using System.Net;
using System.Windows.Forms;

using System.Runtime.InteropServices;

public class Win32Window : IWin32Window {
    private IntPtr _hWnd;

    public Win32Window(IntPtr handle) {
        _hWnd = handle;
    }

    public IntPtr Handle {
        get { return _hWnd; }
    }
}

'@ -ReferencedAssemblies 'System.Windows.Forms.dll'

# based on:  http://www.java2s.com/Tutorial/CSharp/0460__GUI-Windows-Forms/AsimpleBrowser.htm
add-Type @"
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

public class WebBrowserDemo {
	[STAThread]
	public static void Main() {
		Application.EnableVisualStyles();
		Application.Run(new Form1());
	}
}

public class Form1 : Form {
	private String localFile = @"file://c:\developer\sergueik\powershell_ui_samples\test.html";
	// TODO: suppress warning CS0414:
	// because add-Type :  Warning as Error
	private StatusStrip statusStrip1;
	private ToolStripProgressBar toolStripProgressBar1;
	private WebBrowser webBrowser1;
	private void webBrowser1_ProgressChanged(object sender, WebBrowserProgressChangedEventArgs e) {
		toolStripProgressBar1.Maximum = (int)e.MaximumProgress;
		toolStripProgressBar1.Value = (int)e.CurrentProgress;
	}

	private void webBrowser1_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e) {
		toolStripProgressBar1.Value = toolStripProgressBar1.Maximum;     
	}
	
	public Form1() {
		statusStrip1 = new StatusStrip();
		toolStripProgressBar1 = new ToolStripProgressBar();
		webBrowser1 = new WebBrowser();
		statusStrip1.SuspendLayout();
		SuspendLayout();

		statusStrip1.Items.AddRange(new ToolStripItem[] {
			toolStripProgressBar1
		});
		statusStrip1.LayoutStyle = ToolStripLayoutStyle.Table;
		statusStrip1.Location = new System.Drawing.Point(0, 488);
		statusStrip1.Name = "statusStrip1";
		statusStrip1.Size = new System.Drawing.Size(695, 22);
		statusStrip1.TabIndex = 0;
		statusStrip1.Text = "statusStrip1";

		toolStripProgressBar1.DisplayStyle = ToolStripItemDisplayStyle.ImageAndText;
		toolStripProgressBar1.Name = "toolStripProgressBar1";
		toolStripProgressBar1.Size = new System.Drawing.Size(100, 15);
		toolStripProgressBar1.Text = "toolStripProgressBar1";


		webBrowser1.Dock = DockStyle.Fill;
		webBrowser1.Location = new System.Drawing.Point(0, 0);
		webBrowser1.Name = "webBrowser1";
		webBrowser1.Size = new System.Drawing.Size(695, 488);
 
		Console.Error.WriteLine("Loading uri: " + localFile);
		try {
			webBrowser1.Url = new System.Uri(localFile, System.UriKind.Absolute);
			// https://stackoverflow.com/questions/17926197/open-local-file-in-system-windows-forms-webbrowser-control
			// webBrowser1.DocumentText = pageContent;
		} catch (UriFormatException e) {
			Console.Error.WriteLine(e.ToString());
			return;
		} catch (NullReferenceException e) {
			Console.Error.WriteLine(e.ToString());
			return;
		}
		webBrowser1.ProgressChanged += new WebBrowserProgressChangedEventHandler(webBrowser1_ProgressChanged);
		webBrowser1.DocumentCompleted += new WebBrowserDocumentCompletedEventHandler(webBrowser1_DocumentCompleted);

		AutoScaleDimensions = new SizeF(6F, 13F);
		AutoScaleMode = AutoScaleMode.Font;
		ClientSize = new Size(695, 510);
		Controls.Add(webBrowser1);
		Controls.Add(statusStrip1);
		Name = "Form1";
		Text = "Form1";
		statusStrip1.ResumeLayout(false);
		ResumeLayout(false);
		PerformLayout();
	}

	// https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.webbrowser?view=netframework-4.0
	// Navigates to the given URL if it is valid.
	private void Navigate(String address) {
		// TODO: better handle "relative URL"
		var prefix = "file://";
		if (String.IsNullOrEmpty(address))
			return;
		if (address.Equals("about:blank"))
			return;
		if (!address.StartsWith(prefix)) {
			address = prefix + address;
		}
		try {
			webBrowser1.Navigate(new Uri(address));
		} catch (System.UriFormatException) {
			return;
		}
	}

}
"@ -ReferencedAssemblies 'System.Data','System.Drawing','System.Windows.Forms.dll','System.Runtime.InteropServices.dll','System.Net.dll'

function showLocalFile {
  param(
    [string]$file_url = $null,
    [object]$caller = $null
  )
  @( 'System.Drawing','System.Collections','System.ComponentModel','System.Windows.Forms','System.Data') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  $f = new-object System.Windows.Forms.Form
  $f.Text = $title

  $timer1 = new-object System.Timers.Timer
  $label1 = new-object System.Windows.Forms.Label

  $f.SuspendLayout()
  $components = new-object System.ComponentModel.Container

  $browser = new-object System.Windows.Forms.WebBrowser
  $f.SuspendLayout();

  $browser.Dock = [System.Windows.Forms.DockStyle]::Fill
  $browser.Location = new-object System.Drawing.Point (0,0)
  $browser.Name = 'webBrowser1'
  $browser.Size = new-object System.Drawing.Size (600,600)
  $browser.TabIndex = 0

  $f.AutoScaleDimensions = new-object System.Drawing.SizeF (6,13)
  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $f.ClientSize = new-object System.Drawing.Size (600,600)
  $f.Controls.Add($browser)
  $f.Text = 'Show File'
  $f.ResumeLayout($false)
  $pageContent = @'
<html>
  <head>
    <!-- "head" tag is not understood by IE based WebBrowser control, anything here will be displayed -->
  </head>
  <body><h3>Usage:</h3><pre>. ./simple_browser_localfile.ps1 -filename [HTML FILE]</pre><br/>where the <code>[HTML FILE]</code> is looked in the current directory</body>
</html>
'@
  $f.add_Load({
      param([object]$sender,[System.EventArgs]$eventArgs)
      if (($file_url -eq $null ) -or ($file_url -eq '' )){
        $browser.DocumentText = $pageContent
      } else {
        $browser.Navigate($file_url)
      }
    })
  $f.ResumeLayout($false)
  $f.Topmost = $True

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window]($caller))
  $browser.Dispose() 
}

$caller = new-object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
if (($filename -eq $null ) -or ($filename -eq '' )){
  showLocalFile -caller $caller
} else {
  $prefix = 'file://'
  $filepath = ( resolve-path '.' ).Path + '\' + $filename
  $file_url = ('{0}/{1}' -f $prefix, $filepath)
  showLocalFile $file_url $caller
}