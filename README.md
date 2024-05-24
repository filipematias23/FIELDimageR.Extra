## [FIELDimageR.Extra](https://github.com/filipematias23/FIELDimageR.Extra): An package with new tools to support FIELDimageR software on evaluating GIS images from agriculture field trials using [R](https://www.r-project.org).

> This package was developed by [Popat Pawar](https://www.linkedin.com/in/dr-popat-pawar-204bb136/) and [Filipe Matias](https://www.linkedin.com/in/filipe-matias-27bab5199/) to help **FIELDimageR** users with new functions to analyze orthomosaic images from research fields. Cropping and rotating images are not necessary anymore, and there are amazing zoom capabilities provided by newly released GIS R packages. Come along with us and try this tutorial out ... We hope it helps with your research!

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/FIELDimageR_Extra.jpg" width="70%" height="70%">
</p>

<div id="menu" />

---------------------------------------------
## Resources
  
[Installation](#instal)
     
[Step 1. How to start?](#p1)
     
[Step 2. Loading mosaics and visualizing](#p2)

[Step 3. Building the plot shapefile (Zoom)](#p3)

[Step 4. Editing the plot shapefile (Zoom)](#p4)

[Step 5. Building vegetation indices](#p5)

[Step 6. Image segmentation based on unsupervised (K-means) and supervised (Random Forest) methods to remove the soil effect](#p5a)

[Step 7. Extracting data from field images](#p6)

[Step 8. Vizualizing extracted data](#p7)

[Step 9. Saving output files and opening them in the QGIS](#p8) 

[Step 10. Cropping individual plots and saving](#p9)

[Contact](#contact)

<div id="instal" />

---------------------------------------------
### Installation

> First of all, install [R](https://www.r-project.org/) and [RStudio](https://rstudio.com/).
> Then, in order to install R/FIELDimageR.Extra from GitHub [GitHub repository](https://github.com/filipematias23/FIELDimageR.Extra), you need to install the following packages in R. For Windows users who have an R version higher than 4.0, you need to install RTools, tutorial [RTools For Windows](https://cran.r-project.org/bin/windows/Rtools/).

<br />

> Now install R/FIELDimageR.Extra using the `install_github` function from [devtools](https://github.com/hadley/devtools) package. If necessary, use the argument [*type="source"*](https://www.rdocumentation.org/packages/ghit/versions/0.2.18/topics/install_github).

```r
# You may need other packages first:
install.packages(c('terra','mapview','sf','stars','caret','mapedit','devtools',"dplyr","fields","leafem","leafsync","lwgeom","BiocManager"))
BiocManager::install("EBImage")

# FIELDimageR:
devtools::install_github("filipematias23/FIELDimageR.Extra")
devtools::install_github("OpenDroneMap/FIELDimageR")

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

<div id="p1" />

---------------------------------------------

### Using R/FIELDimageR.Extra


<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex0.jpg" width="80%" height="80%">
</p>


#### 1. First steps

> **Reading necessary packages:**
```r
# Packages:
library(FIELDimageR)
library(FIELDimageR.Extra)
library(terra)
library(mapview)
library(sf)
library(stars)
```
[Menu](#menu)

<div id="p2" />

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

<div id="p3" />

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

>  Users can use a specific plot size to build the grid shape file by informing X and Y plot length in the parameter **`plot_size`**. It´s very important to highlight the applied values are connected with the mosaic resolution and unit. For example, **`plot_size=c(0.6,4)`** means **0.6m by 4m** or **60cm by 400cm** in the example below.

```r
### Building the plot shapefile using specific plot sizes with the parameter 'plot_size':

plotShape_plotSize<-fieldShape_render(mosaic = Test,
                             ncols=14,
                             nrows=9,
                             fieldData = DataTable,
                             fieldMap = fieldMap,
                             PlotID = "Plot",
                             plot_size = c(0.6,4))

# Checking the new plot grid shapefile using plot_size = c(0.6,4):
fieldView(mosaic = Test,
          fieldShape = plotShape_plotSize,
          type = 2,
          alpha = 0.2)                      
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex9a.jpg" width="60%" height="60%">
</p>

<br />

[Menu](#menu)

<div id="p4" />

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

<div id="p5" />

---------------------------------------------
#### 5. Building vegetation indices

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

fieldView(single_layer,
          fieldShape = editShape,
          plotCol = c("Yield"),
          colorOptions = 'RdYlGn',
          type = 1,
          alpha_grid = 0.8)
```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex11.jpg">
</p>

<br />

[Menu](#menu)

<div id="p5a" />

---------------------------------------------
#### 6. Removing the soil effect

> FIELDimageR.Extra introduce the function **`fieldKmeans`** as the first option to remove soil (Option_01). Based on the K-means unsupervised method. This function clusters pixels on the number of clusters decided by the user. Each cluster can be associated with plants, soil, shadows, etc. *Attention:* Each image/mosaic will have different cluster numbers representing plants or soil. In this example, cluster_01 is plants and cluster_02 is soil.

```r
# Option_01 = Using fieldKmeans() to extract soil
Test.kmean<-fieldKmeans(mosaic=Test.Indices$GLI,
                   clusters = 2)
fieldView(Test.kmean)

# Check which cluster is related to plants or soil based on the color. In this example cluster 1 represents plants and cluster 2 represents soil
library(leafsync)
rgb<-fieldView(Test)
plants<-fieldView(Test.kmean==1)
sync(rgb,plants)

# Soil Mask (cluster 2) to remove soil effect from the mosaic using FIELDimageR::fieldMask :
soil<-Test.kmean==2
Test.RemSoil<-fieldMask(Test.Indices,
                        mask = soil) 
fieldView(Test.RemSoil$newMosaic,
          fieldShape = editShape,
          type = 2,
          alpha_grid = 0.2)

```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex12a.jpg" width="80%" height="80%">
</p>

<br />

> Option 02 is the new function [**`fieldSegment`**]. This function uses samples of images and machine learning algorithms for pixel classification (Supervised method). There are two models included *Random Forest* (default) and *cart*. Initially, users need to create training samples by using **fieldView** function by enabling the editor option to digitize spatial object (e.g. soil, plant, shadow etc.). For instance, users need to utilize the draw polygon or draw rectangle tool in the editor. The mapedit objects have 0.000001 degree spatial resolution, about 10 cm at the equator (Source: https://github.com/r-spatial/mapedit/issues/63). For images with coarse spatial resolution, this level of precision won't significantly affect digitization accuracy. However, for UAV images with high spatial resolution, this precision (around 10 cm) can significantly impact the accuracy of digitization. Therefore, using the pointer tool in the editor for digitizing small objects like flowers could potentially lead to inaccuracies in the digitization position. For accurate results, prefer to draw polygon or rectangle tools in the editor for digitizing larger size objects. For digitizing smaller objects(e.g. flowers) users can use QGIS software and use it for further analysis in R.

```r

### Option_02 = Using fieldSegment()

# Digitize soil object by drawing polygons at least 5-6 large polygon uniformly distributed
soil<-fieldView(mosaic = Test, editor = TRUE) #generate random 200 points for soil class
soil<-st_as_sf(st_sample(soil, 200))
soil$class<-'soil'

# Digitize plants object by drawing polygons. The number of polygon will depends upon the number of training points to be generated.
plants<-fieldView(mosaic = Test, editor = TRUE)
plants<-st_as_sf(st_sample(plants, 200)) #generate random 200 points for plants class
plants$class<-'plants'

#similarly you can digitize shadow, other objects by using draw polygon tool of editor
training_sam<-rbind(soil,plants)

# Random Forest model:
classification<-fieldSegment(mosaic = Test, 
                             trainDataset = training_sam)

# To display results of classification from randomForest
classification$sup_model
classification$pred
classification$rastPred
fieldView(classification$rastPred)
plot(classification$rastPred)

# Creating a mask to remove soil from the original image:
soil<-classification$rastPred=="soil"
Test.RemSoil<-fieldMask(Test.Indices,
                        mask = soil) 
fieldView(Test.RemSoil$newMosaic,
          fieldShape = editShape,
          type = 2,
          alpha_grid = 0.2)
     
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex12b.jpg" width="80%" height="80%">
</p>

<br />

> Option 03 is the traditional way to remove soil using the function [**`FIELDimageR::fieldMask`**](https://github.com/OpenDroneMap/FIELDimageR#P4) from FIELDimageR package (Thresholding Method). 

```r

# Option_03 = Using the traditional FIELDimageR::fieldMask()
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
#### 7. Extracting data from field images 

> The function *aggregate* from **[stars](https://r-spatial.github.io/stars/reference/aggregate.stars.html)** was adapted for agricultural field experiments through function **`fieldInfo_extra`**. 

```r
DataTotal<- fieldInfo_extra(mosaic = Test.RemSoil$newMosaic,
                    fieldShape = editShape, 
                    fun = "mean")
DataTotal
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex13.jpg">
</p>

<br />

[Menu](#menu)

<div id="p7" />

---------------------------------------------
#### 8. Vizualizing extracted data

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
m1<-viewRGB(as(Test.RemSoil$newMosaic, "Raster"))
m2<-mapview(as(Test.RemSoil$newMosaic$NGRDI, "Raster"),layer.name="NGRDI")
m3<-mapview(as(Test.RemSoil$newMosaic$BGI, "Raster"),layer.name="BGI")
m4<-mapview(DataTotal,zcol="Yield")
sync(m1,m2,m3,m4)
```
<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/Fex17.jpg">
</p>

<br />

[Menu](#menu)

<div id="p8" />

---------------------------------------------
#### 9. Saving output files and opening them in the QGIS

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
#### 10. Cropping individual plots and saving

> Many times when developing algorithms it is necessary to crop the mosaic using the plot fieldShape as a reference and sort/store cropped plot images on specific folders. For instance, the function **`fieldCrop_grid`** allows cropping plots and identification by 'plotID'. The user also can save each plot according to a 'classifier' logic (Attention: a column in the 'fieldShape' with the desired classification must be informed). In the example below, each plot in the 'Test.Indices' mosaic is being cropped according to the 'editShape' grid file, identified by the information in the 'plot' column, and stored/saved in specific folders with different levels of Maturity the 'classifier'.

```r
# Saving plot images format .jpg according to 'Maturity': 
Field_plot_grids<- fieldCrop_grid(mosaic = Test.Indices, # if necessary use rast(Test.Indices)
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
Field_plot_grids<- fieldCrop_grid(mosaic = Test.Indices, # if necessary use rast(Test.Indices) 
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

* *Pawar P. & Matias FI.* FIELDimageR.Extra: Advancing user experience and computational efficiency for analysis of orthomosaic from agricultural field trials. **The Plant Phenome J.** 2023; [https://doi.org/10.1002/ppj2.20083](https://doi.org/10.1002/ppj2.20083)

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
> * [Phenome-Force Channel](https://youtube.com/@phenomeforce6569)
> * [r-spatial community](https://github.com/r-spatial)

<br />

[Menu](#menu)

<br />
