# Create geodatabase state tree diagram
This tool provides three ways to visualize SDE database version states and their relationships in ArcGIS desktop.
### Installation (quick and easy)
* As needed install [R 3.3.2 or later](http://cran.cnr.berkeley.edu/bin/windows/base/).
* Install [The R-ArcGIS bridge](https://r-arcgis.github.io/). [Install with ArcGIS Pro](https://learn.arcgis.com/en/projects/analyze-crime-using-statistics-and-the-r-arcgis-bridge/lessons/install-the-r-arcgis-bridge-and-start-statistical-analysis.htm#ESRI_SECTION1_D4D9FAD231DC4FA287EECCBEC4A11723) (Note: At step 3 be patient as it takes a moment for the home directories list to be populated) or [follow the instructions](https://github.com/R-ArcGIS/r-bridge-install) for installing offline or with ArcMap.
* Download and unzip a copy of this repository in a convenient location.  The StateTreeFiles folder must remain in the same location relative to the toolbox.
### Running the tool
1. In ArcGIS Pro or ArcMap browse to the repository folder and open the Create_State_Diagram toolbox in the catalog window and open the Create state tree diagram model.
2. Browse to the desired database connection file - note: the connection must use geodatabase administrator credentials.
3. Select one or more of the desired output formats.
4. Click Run or OK.  (The first time the model runs it will install the needed external packages).
### Notes
* The diagram features are added to the current map without a spatial reference and centered near 0, 0.  This seems to work fine with an empty map document in ArcMap or a map with default Web Mercator projection in ArcGIS Pro.  In some cases, it may be necessary to zoom to the features to view the diagram and experiences with other spatial references and projections may vary.
* The default symbology and labels of the created features can be changed in ArcMap by symbolizing a diagram as desired and saving layer files over the default files stored in the StateTreeFiles folder.
### Known limitations
* If the Y dimension of the diagram is very large ArcMap or ArcGIS Pro will crash.
* Please report any issues!
