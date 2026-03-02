<img style='margin: 0 auto' src="https://github.com/jakob/TableTool/raw/master/Table%20Tool/Images.xcassets/AppIcon.appiconset/icon_128x128@2x.png" width=128 height=128>

# Table Tool 

A simple CSV editor for OS X.

Download [on the Mac App Store](https://itunes.apple.com/app/table-tool/id1122008420?mt=12).

<img style='margin: 0 auto' src="https://github.com/jakob/TableTool/raw/master/Artwork/Screenshots/2016-06-08 Tabletool 1.1 Customers.jpg" width=800 height=500>

The CSV format is a common used file format to store and exchange tabular data. 
Almost all spreadsheet and database apps (e.g. Excel and Numbers) support it.
Unfortunately, not all CSV files are made equal.
CSV files use different record delimiters (comma or semicolon), character encodings, decimal separators or quoting styles.

TableTool handles these issues automatically.
It detects the specification of a CSV file for you and displays its contents in a table view.
Using TableTool is the easy way to create, edit and convert CSV files.

## Usage

**Open Files:**
When opening a CSV file, Table Tool detects the format specifications 
(record delimiter, character encoding, etc.) automatically.
You can also set the specifications manually.

**Edit Files:**
Edit the contents of the cells, rows and columns of the document easily in a grid based user interface.

**Convert Files:**
Convert an existing CSV file to a different format.

## Testing Builds

CI builds are generated automatically for every push and pull request. To download and run a testing build:

1. Open the [Actions tab](../../actions/workflows/ci.yml) and click the latest successful run.
2. Scroll to the **Artifacts** section and download **TableTool-\<sha\>.zip**.
3. Unzip the file — you will find **Table Tool.app** and **Open Table Tool.command**.
4. **Double-click `Open Table Tool.command`** in Finder to launch the app.

> **Why the launch script?** macOS Gatekeeper quarantines every file downloaded from the internet. Because this is an ad-hoc–signed development build (not distributed through the Mac App Store or notarized), macOS will block it from opening directly. The `Open Table Tool.command` script removes the quarantine attribute and then opens the app. You may be prompted to allow Terminal to run the script — click **OK**.

Alternatively, you can remove the quarantine attribute yourself from the Terminal:

```bash
xattr -rd com.apple.quarantine "/path/to/Table Tool.app"
open "/path/to/Table Tool.app"
```

## Credits

Table Tool was made by [Sandro Peham](https://github.com/SandroPeham), 
[Andreas Aigner](https://github.com/aigi) and 
[Jakob Egger](https://github.com/jakob).

## Mission / Project Scope / Contributing

TableTool seeks to be a great and simple CSV file editor and nothing more. Any formatting options or features like formulas will be out of scope for the project. Please post an issue if something is broken ([bug](https://github.com/jakob/TableTool/labels/bug)) or you believe something is missing ([feature request](https://github.com/jakob/TableTool/labels/enhancement)) and please be prepared to [provide screenshots](https://github.com/jakob/TableTool/labels/need%20mockup). We will endeavor to quickly decide if the thing is actually broken or if the new feature belongs in the project ([help-wanted](https://github.com/jakob/TableTool/labels/help%20wanted) label). Once the help-wanted label is set, please help to work on implementation for that feature and we are happy to accept a pull request for it. We currently have more side projects than we can handle, so well documented issues and great pull requests will help move this project forward. We are happy to give commit access to consistent contributors.

## Licence

Table Tool is distributed under the [MIT Licence](https://github.com/jakob/TableTool/blob/master/LICENSE).
