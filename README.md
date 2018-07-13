# Create geodatabase state tree diagram
This tool provides three ways to visualize SDE database version states and their relationships in ArcGIS desktop.
### Requirements
* [R 3.3.2 or later](http://cran.cnr.berkeley.edu/bin/windows/base/). 
* [ArcGIS 10.3.1 or later](http://desktop.arcgis.com/en/desktop/) or [ArcGIS Pro 1.1 or later](http://pro.arcgis.com/en/pro-app/).
* [Install the R-ArcGIS bridge via ArcGIS Pro](https://learn.arcgis.com/en/projects/analyze-crime-using-statistics-and-the-r-arcgis-bridge/lessons/install-the-r-arcgis-bridge-and-start-statistical-analysis.htm#ESRI_SECTION1_D4D9FAD231DC4FA287EECCBEC4A11723) (Note: At step 3 be patient as it takes a moment for the home directories list to be populated).  Or [follow the instructions](https://github.com/R-ArcGIS/r-bridge-install) for installing offline or with ArcMap.
* Unzip the tool folder with toolbox and associated files in a convenient location.  The StateTreeFiles folder must remain in the same location relative to the toolbox.
### Running the tool
1. Open the Create_State_Diagram toolbox in the catalog window in ArcGIS Pro or ArcMap and open the Create state tree diagram tool.
2. Browse to the desired database connection file - note: the connection file used must have geodatabase administrator credentials.
3. Select one or more of the desired output formats.
4. Click Run or OK.  (The first time the tool runs it will install the needed external packages).
### Known limitations
* If the Y dimension of the diagram is very large ArcMap or ArcGIS Pro will crash.
