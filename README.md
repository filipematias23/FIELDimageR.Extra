## [FIELDimageR.Extra](https://github.com/filipematias23/FIELDimageR.Extra): An package with new tools to support FIELDimageR software on evaluating GIS images from agriculture field trials using [R](https://www.r-project.org).

> This package was developed by [Popat Pawar](https://www.linkedin.com/in/dr-popat-pawar-204bb136/) and [Filipe Matias](https://www.linkedin.com/in/filipe-matias-27bab5199/) to help **FIELDimageR** users with new functions to analyze orthomosaic images from research fields. Cropping and rotating images are not necessary anymore, and there are amazing zoom capabilities provided by newly released GIS R packages. Come along with us and try this tutorial out ... We hope it helps with your research!

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/FIELDimageR_Extra.jpg" width="70%" height="70%">
</p>

<div id="menu" />

---------------------------------------------
## Resources
  
[Installation](#Instal)
     
[Step 1. How to start?](#P1)
     
[Step 2. Loading mosaics and visualizing](#P2)

[Step 3. Building the plot shapefile (Zoom)](#P3)

[Step 4. Editing the plot shapefile (Zoom)](#P4)

[Step 5. Building vegetation indices and removing the soil effect](#P5)

[Step 6. Extracting data from field images](#p6)

[Step 7. Vizualizing extracted data](#P7)

[Step 8. Saving output files and opening them in the QGIS](#P8) 

[Step 9. Cropping individual plots and saving](#p9)

[Contact](#contact)

<div id="Instal" />

---------------------------------------------
### Installation

> First of all, install [R](https://www.r-project.org/) and [RStudio](https://rstudio.com/).
> Then, in order to install R/FIELDimageR.Extra from GitHub [GitHub repository](https://github.com/filipematias23/FIELDimageR.Extra), you need to install the following packages in R. For Windows users who have an R version higher than 4.0, you need to install RTools, tutorial [RTools For Windows](https://cran.r-project.org/bin/windows/Rtools/).

<br />

> Now install R/FIELDimageR.Extra using the `install_github` function from [devtools](https://github.com/hadley/devtools) package. If necessary, use the argument [*type="source"*](https://www.rdocumentation.org/packages/ghit/versions/0.2.18/topics/install_github).

```r
install.packages("devtools")
devtools::install_github("filipematias23/FIELDimageR.Extra")
```

<br />

> If the method above doesn't work, use the next lines by downloading the FIELDimageR-master.zip file

```r
setwd("~/FIELDimageR.Extra-main.zip") # ~ is the path from where you saved the file.zip
unzip("FIELDimageR.Extra-main.zip") 
file.rename("FIELDimageR.Extra-main", "FIELDimageR.Extra") 
shell("R CMD build FIELDimageR.Extra") # or system("R CMD build FIELDimageR.Extra")
install.packages("FIELDimageR.Extra_0.0.1.tar.gz", repos = NULL, type="source") # Make sure to use the right version (e.g. 0.0.1)
```
<br />

> The image below from **R/FIELDimageR** is highlighting how to do the steps described above and install **R/FIELDimageR.Extra** using source code.

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Install.jpg" width="50%" height="50%">
</p>

<br />


[Menu](#menu)

<div id="P1" />

---------------------------------------------

### Using R/FIELDimageR.Extra


<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex0.jpg" width="80%" height="80%">
</p>


#### 1. First steps

> **Reading necessary packages:**
```r
# Install:
install.packages(c("BGGE",'mapview','sf','stars'))
devtools::install_github("OpenDroneMap/FIELDimageR")

# Packages:
library(FIELDimageR)
library(FIELDimageR.Extra)
library(terra)
library(mapview)
library(sf)
library(stars)
```
[Menu](#menu)

<div id="P2" />

---------------------------------------------
#### 2. Loading mosaics and visualizing

> The following example uses an image available to download here: [EX1_RGB.tif](https://drive.google.com/open?id=1S9MyX12De94swjtDuEXMZKhIIHbXkXKt). The first R/FIELDimageR.Extra function is **`fieldView`** used to visualize GIS images and grid shapefiles and zoom it out.

```r

# Uploading an example mosaic
Test <- rast("EX1_RGB.tif")

# Visualization Option-01 (FIELDimageR.Extra):
fieldView(Test)

```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex1.jpg" width="80%" height="80%">
</p>

<br />

```r

# Visualization Option-02 (raster):
plotRGB(Test)

```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex2.jpg" width="80%" height="80%">
</p>

<br />

[Menu](#menu)

<div id="P3" />

---------------------------------------------
#### 3. Building the plot shapefile (Zoom)

> FIELDimageR.Extra allows drawing the plot shape file using the function **`fieldShape_render`**. Different from **`FIELDimageR::fieldShape`** this new function does not request straight fields and the experimental trial can be used in any direction according to the original GIS position. It is very important to highlight that **four points** need to be set at the corners of the trial according to the following sequence (1st point) left superior corner, (2nd point) right superior corner, (3rd point) right inferior corner, and (4th point) left inferior corner. The mosaic will be presented for visualization with the North part on the superior part (top) and the south in )the inferior part (bottom). The number of columns and rows must be informed. At this point, the experimental borders can be eliminated (check the example below. 

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex4.jpg" width="70%" height="70%">
</p>

```r
plotShape<-fieldShape_render(mosaic = Test,
                             ncols=14,
                             nrows=9)

```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex3.jpg">
</p>

<br />

> **Attention:** The plots are identified in ascending order from *left to right* and *bottom to top* (this is another difference from the **`FIELDimageR::fieldShape`** ) being evenly spaced and distributed inside the selected area independent of alleys. 

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex5.jpg" width="60%" height="60%">
</p>

<br />

>  One matrix can be used to identify the plots position according to the image above. The function **`FIELDimageR::fieldMap`** can be used to specify the plot *ID* automatic or any other matrix (manually built) also can be used. For instance, the new column **PlotID** will be the new identification. You can download an external table example here: [DataTable.csv](https://drive.google.com/open?id=18YE4dlSY1Czk2nKeHgwd9xBX8Yu6RCl7).

```r
# Reading DataTable.csv
DataTable<-read.csv("DataTable.csv",header = T)
DataTable
```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex6.jpg" width="60%" height="60%">
</p>

<br />

```r

### Field map identification (name for each Plot). 'fieldPlot' argument can be a number or name.

fieldMap<-fieldMap(fieldPlot=DataTable$Plot, fieldColumn=DataTable$Row, fieldRow=DataTable$Range, decreasing=T)
fieldMap

# The new column PlotID is identifying the plots:
plotShape<-fieldShape_render(mosaic = Test,
                             ncols=14,
                             nrows=9,
                             fieldMap = fieldMap,
                             buffer = -0.05)
```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex7.jpg" width="60%" height="60%">
</p>

<br />


```r
### Joing all information from 'fieldData' in one "fieldShape" file using the column 'Plot' as reference:

plotShape<-fieldShape_render(mosaic = Test,
                             ncols=14,
                             nrows=9,
                             fieldData = DataTable,
                             fieldMap = fieldMap,
                             PlotID = "Plot",
                             buffer = -0.05)
                      
# The new column PlotID is identifying the plots:                      
plotShape

# Vizualizing new plot grid shape object with field data:
fieldView(mosaic = Test,
          fieldShape = plotShape,
          type = 2,
          alpha = 0.2)
                      
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex8.jpg" width="80%" height="80%">
</p>

<br />

```r
### Different plot dimensions using "Buffer":

# Buffer = NULL
Buffer.1<-fieldShape_render(mosaic = Test,
                             ncols=14,
                             nrows=9)
fieldView(mosaic = Test,
          fieldShape = Buffer.1,
          type = 2,
          alpha = 0.2)

# Buffer = -0.05
Buffer.2<-fieldShape_render(mosaic = Test,
                             ncols=14,
                             nrows=9,
                             buffer = -0.05)
fieldView(mosaic = Test,
          fieldShape = Buffer.2,
          type = 2,
          alpha = 0.2)

# Buffer = -0.10
Buffer.3<-fieldShape_render(mosaic = Test,
                             ncols=14,
                             nrows=9,
                             buffer = -0.10)
fieldView(mosaic = Test,
          fieldShape = Buffer.3,
          type = 2,
          alpha = 0.2)

# Buffer = -0.20
Buffer.4<-fieldShape_render(mosaic = Test,
                             ncols=14,
                             nrows=9,
                             buffer = -0.20)
fieldView(mosaic = Test,
          fieldShape = Buffer.4,
          type = 2,
          alpha = 0.2)              
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex9.jpg" width="60%" height="60%">
</p>

<br />

[Menu](#menu)

<div id="P4" />

---------------------------------------------
#### 4. Editing plot shapefile (Zoom) 

> Editing, moving, deleting, and changing single plot grids in fieldShape objects is now possible with the function **`fieldShape_edit`**. Follow the image bellow to understand how this function works. Attention: do not forget to press *SAVE* before clicking on *DONE*.

```r
# Editing plot grid shapefile:
editShape<- fieldShape_edit(mosaic=Test,
                            fieldShape=plotShape)

# Checking the edited plot grid shapefile:
fieldView(mosaic = Test,
          fieldShape = editShape,
          type = 2,
          alpha = 0.2)

```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex10.jpg">
</p>

<br />

[Menu](#menu)

<div id="P5" />

---------------------------------------------
#### 5. Building vegetation indices and removing the soil effect

> Vegetation indices still being calculated using the function [**`FIELDimageR::fieldIndex`**](https://github.com/OpenDroneMap/FIELDimageR#P6) from FIELDimageR package.

```r
# Vegetation indices:
Test.Indices<- fieldIndex(mosaic = Test, 
                          Red = 1, Green = 2, Blue = 3, 
                          index = c("NGRDI","BGI", "GLI","VARI"), 
                          myIndex = c("(Red-Blue)/Green","2*Green/Blue"))

# To visualize single band layer:
single_layer<-Test.Indices$GLI
fieldView(single_layer,
          fieldShape = editShape,
          type = 2,
          alpha_grid = 0.2)  
```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex11.jpg">
</p>

<br />

> In the same way, removing soil step continues being made by the function [**`FIELDimageR::fieldMask`**](https://github.com/OpenDroneMap/FIELDimageR#P4) from FIELDimageR package.

```r
# Removing soil and making a mask
Test.RemSoil<-fieldMask(Test.Indices)

fieldView(Test.RemSoil$newMosaic,
          fieldShape = editShape,
          type = 2,
          alpha_grid = 0.2)
      
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex12.jpg" width="80%" height="80%">
</p>

<br />

[Menu](#menu)

<div id="p6" />

---------------------------------------------
#### 6. Extracting data from field images 

> The function *aggregate* from **[stars](https://r-spatial.github.io/stars/reference/aggregate.stars.html)** was adapted for agricultural field experiments through function **`fieldInfo_extra`**. 

```r
DataTotal<- fieldInfo_extra(mosaic = Test.RemSoil$newMosaic,
                    fieldShape = editShape, 
                    fun = mean)
DataTotal
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex13.jpg">
</p>

<br />

[Menu](#menu)

<div id="P7" />

---------------------------------------------
#### 7. Vizualizing extracted data

> There are different ways to use the function **`fieldView`** to visualize and interpret extracted data.  

```r
# Visualizing single layer vegetation index 'BGI': 
fieldView(mosaic = Test.RemSoil$newMosaic,
          fieldShape = DataTotal,
          plotCol = "BGI",
          type = 2,
          alpha_grid = 0.6)
```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex14a.jpg" width="80%" height="80%">
</p>

<br />

```r
# Applying different color schemes to paint plots in the fieldShape file. An example using extracted values for 'BGI': 
fieldView(mosaic = Test.RemSoil$newMosaic,
          fieldShape = DataTotal,
          plotCol = "BGI",
          col_grid = c("blue", "grey", "red"),
          type = 2,
          alpha_grid = 0.6)
```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex14.jpg" width="80%" height="80%">
</p>

<br />

```r
# Coloring fieldShape file using 'Yield' to highlight plots: 
fieldView(mosaic = Test.RemSoil$newMosaic,
          fieldShape = DataTotal,
          plotCol = c("Yield"),
          type = 1)
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex15.jpg" width="70%" height="70%">
</p>

<br />

```r
# Coloring fieldShape file using more traits: 
fieldView(mosaic = Test.RemSoil$newMosaic,
          fieldShape = DataTotal,
          plotCol = c("Yield","GLI"),
          type = 1)
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex16.jpg" width="80%" height="80%">
</p>

<br />

```r
# Syncronizing individual layers:
library(leafsync)
m1<-viewRGB(Test.RemSoil$newMosaic)
m2<-mapview(Test.RemSoil$newMosaic$NGRDI,layer.name="NGRDI")
m3<-mapview(Test.RemSoil$newMosaic$BGI,layer.name="BGI")
m4<-mapview(DataTotal,zcol="Yield")
sync(m1,m2,m3,m4)
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex17.jpg">
</p>

<br />

[Menu](#menu)

<div id="P8" />

---------------------------------------------
#### 8. Saving output files and opening them in the QGIS

```r
# Saving Data.csv (You can remove the 'geometry' info):
write.csv(as.data.frame(DataTotal)[,-dim(DataTotal)[2]],"DataTotal.csv",col.names = T, row.names = F)

# Saving grid fieldShape file:
st_write(DataTotal,"grid.shp")

# To read saved.shp object:
Saved_Grid= st_read("grid.shp")

```

> The saved **"grid.shp"** can be opened on others GIS softwares as [*QGIS*](). Users can easily upload the orthomosaic and grid.shp by holding the file from the folder and dragging it to a new project at QGIS. There are different visualization possibilities in QGIS. In the example below, each plot was identified according to the maturity score. However, any vegetation index calculated with **FIELDimageR::fieldIndex** can be visualized as well. 

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex20.jpg" width="80%" height="80%">
</p>

<br />

[Menu](#menu)

<div id="p9" />

---------------------------------------------
#### 9. Cropping individual plots and saving

> Many times when developing algorithms it is necessary to crop the mosaic using the plot fieldShape as a reference and sort/store cropped plot images on specific folders. For instance, the function **`fieldCrop_grid`** allows cropping plots and identification by 'plotID'. The user also can save each plot according to a 'classifier' logic (Attention: a column in the 'fieldShape' with the desired classification must be informed). In the example below, each plot in the 'Test.Indices' mosaic is being cropped according to the 'editShape' grid file, identified by the information in the 'plot' column, and stored/saved in specific folders with different levels of Maturity the 'classifier'.

```r
# Saving plot images format .jpg according to 'Maturity': 
Field_plot_grids<- fieldCrop_grid(mosaic = rast(Test.Indices),
                                  fieldShape = editShape, 
                                  classifier = "Maturity", 
                                  plotID = "Plot",
                                  format = '.jpg',
                                  output_dir = "./")

# Visualizing plot "#21"
fieldView(Field_plot_grids$'21')

```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex18.jpg" width="80%" height="80%">
</p>

<br />

```r
# Saving plot images format .tif according to 'Maturity':
Field_plot_grids<- fieldCrop_grid(mosaic = rast(Test.Indices),
                                  fieldShape = editShape, 
                                  classifier = "Maturity", 
                                  plotID = "Plot",
                                  format = '.tif',
                                  output_dir = "./")

# Reading .tif file and visualizing single plots with fieldView()
tif<-rast("./2/21.tif")
fieldView(mosaic = tif,
          fieldShape = editShape,
          plotCol ="Maturity")
```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex19.jpg" width="60%" height="60%">
</p>

<br />

[Menu](#menu)

<div id="contact" />

---------------------------------------------
### Google Groups Forum

> This discussion group provides an online source of information about the FIELDimageR package. Report a bug and ask a question at: 
* https://groups.google.com/forum/#!forum/fieldimager 
* https://community.opendronemap.org/t/about-the-fieldimager-category/4130

<br />

### Developers
> **Help improve FIELDimageR.Extra pipeline**. The easiest way to modify the package is by cloning the repository and making changes using [R projects](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects).

> If you have questions, join the forum group at https://groups.google.com/forum/#!forum/fieldimager

>Try to keep commits clean and simple

>Submit a **_pull request_** with detailed changes and test results.

**Let's  work together and help more people (students, professors, farmers, etc) to have access to this knowledge. Thus, anyone anywhere can learn how to apply remote sensing in agriculture.** 

<br />

### Licenses

> The R/FIELDimageR package as a whole is distributed under [GPL-3 (GNU General Public License version 3)](https://www.gnu.org/licenses/gpl-3.0.en.html).

<br />

### Citation

*Pawar P & Matias FI.* FIELDimageR.Extra. (2023) (Submited)

* *Matias FI, Caraza-Harter MV, Endelman JB.* FIELDimageR: An R package to analyze orthomosaic images from agricultural field trials. **The Plant Phenome J.** 2020; [https://doi.org/10.1002/ppj2.20005](https://doi.org/10.1002/ppj2.20005)

<br />

### Author

> Popat Pawar
* [GitHub](https://github.com/pspawar71)
* [LinkedIn](https://www.linkedin.com/in/dr-popat-pawar-204bb136/)
* E-mail: pspawar71@gmail.com
  
> Filipe Matias
* [GitHub](https://github.com/filipematias23)
* [LinkedIn](https://www.linkedin.com/in/filipe-matias-27bab5199/)
* E-mail: filipematias23@gmail.com

<br />

### Acknowledgments

> * [OpenDroneMap](https://www.opendronemap.org/)

<br />

[Menu](#menu)

<br />
