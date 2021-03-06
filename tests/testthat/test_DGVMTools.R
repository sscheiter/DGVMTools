library(testthat)
library(DGVMTools)
library(FireMIPTools)
library(stats)
library(compiler)



# SOURCE 
context("Source")

GUESS.Europe.test.Source <- defineSource(id = "LPJ-GUESS_Example",
                            dir = system.file("extdata", "LPJ-GUESS_Runs", "CentralEurope", package = "DGVMTools"), 
                            format = GUESS,
                            name = "LPJ-GUESS Europe Example Run")

GUESS.Africa.test.Source <- defineSource(id = "LPJ-GUESS_Example",
                                     dir = system.file("extdata", "LPJ-GUESS_Runs", "CentralAfrica", package = "DGVMTools"), 
                                     format = GUESS,
                                     name = "LPJ-GUESS Africa Example Run")


DGVMData.PNVBiomes.test.Source <- defineSource(id = "HandP_PNV",
                                     dir = system.file("extdata", "DGVMData", "HandP_PNV", "HD", package = "DGVMTools"), 
                                     format = DGVMData,
                                     name = "Haxeltine & Prentice 1996 PNV Biomes")


DGVMData.SaatchiBiomass.test.Source <- defineSource(id = "Saatchi2011",
                                             dir = system.file("extdata", "DGVMData", "Saatchi2011", "HD", package = "DGVMTools"), 
                                             format = DGVMData,
                                             name = "Saatchi et al. 2011 Vegetation Carbon")

# test Source and Field
test_that("Sources",{
  
  expect_is(GUESS.Europe.test.Source, "Source")
  expect_is(GUESS.Africa.test.Source, "Source")
  expect_is(DGVMData.SaatchiBiomass.test.Source, "Source")
  expect_is(DGVMData.PNVBiomes.test.Source, "Source")
  
})


# QUANTITY OBJECTS 
context("Quantity")

vegC_std.Quantity <- lookupQuantity("vegC_std")
LAI_FireMIP.Quantity <- lookupQuantity("lai", context = FireMIP.quantities)


test_that("Quantity",{

  expect_is(vegC_std.Quantity , "Quantity")
  expect_is(LAI_FireMIP.Quantity  , "Quantity")
  
})



# FIELD
context("Field")

# get Fields for checking and also using later
GUESS.mlai.Field.full <- getField(GUESS.Europe.test.Source, "mlai")
GUESS.lai.Field.full <- getField(GUESS.Europe.test.Source, "lai")
GUESS.cmass.Field.full <- getField(GUESS.Africa.test.Source, "cmass")
GUESS.vegC_std.Field.full <- getField(GUESS.Africa.test.Source, vegC_std.Quantity)
Saatchi.Field.full <- getField(DGVMData.SaatchiBiomass.test.Source, vegC_std.Quantity)
Biomes.Field.full <- getField(DGVMData.PNVBiomes.test.Source, "Smith2014")


# test Source and Field
test_that("Field",{
  
  # Normal LPJ-GUESS variable
  expect_is(GUESS.mlai.Field.full, "Field")
  expect_is(GUESS.lai.Field.full, "Field")
  expect_is(GUESS.cmass.Field.full, "Field")
  expect_is(GUESS.vegC_std.Field.full, "Field")
  expect_is(Saatchi.Field.full, "Field")
  expect_is(Biomes.Field.full, "Field")
  
  
  # Also check "Standard" and FireMIP variables
  Standard.Field <- getField(GUESS.Europe.test.Source, "LAI_std")
  FireMIP.Field <- getField(GUESS.Europe.test.Source, LAI_FireMIP.Quantity)
  expect_is(Standard.Field, "Field")
  expect_is(FireMIP.Field, "Field")
  
  # Check the data are the same
  expect_identical(Standard.Field@data, GUESS.lai.Field.full@data)
  expect_identical(FireMIP.Field@data, GUESS.lai.Field.full@data)
  
  # check the DGVMData
  expect_is(Saatchi.Field.full, "Field")
  expect_is(Biomes.Field.full, "Field")
  
  
})


# AGGREGATIONS
context("Aggregations")

# subannual to monthly
GUESS.Field.monthly.mean.1 <- getField(GUESS.Europe.test.Source, "mlai", subannual.aggregate.method = "mean", subannual.resolution = "Year")
GUESS.Field.monthly.mean.2 <- aggregateSubannual(input.obj = GUESS.mlai.Field.full, method = "mean", target = "Year")
# subannual to seasonal
GUESS.Field.seasonal.mean.1 <- getField(GUESS.Europe.test.Source, "mlai", subannual.aggregate.method = "mean", subannual.resolution = "Season")
GUESS.Field.seasonal.mean.2 <- aggregateSubannual(input.obj = GUESS.mlai.Field.full, method = "mean", target = "Season")
# yearly
GUESS.Field.yearly.mean.1 <- getField(GUESS.Europe.test.Source, "mlai", year.aggregate.method = "mean")
GUESS.Field.yearly.mean.2 <- aggregateYears(GUESS.mlai.Field.full, "mean")
# spatial
GUESS.Field.spatial.mean.1 <- getField(GUESS.Europe.test.Source, "mlai", spatial.aggregate.method = "mean")
GUESS.Field.spatial.mean.2 <- aggregateSpatial(GUESS.mlai.Field.full, "mean")


# test aggregations
test_that("Aggregation",{
  
  # check they give Field
  expect_is(GUESS.Field.monthly.mean.1, "Field")
  expect_is(GUESS.Field.monthly.mean.2, "Field")
  expect_is(GUESS.Field.seasonal.mean.1, "Field")
  expect_is(GUESS.Field.seasonal.mean.2, "Field")
  expect_is(GUESS.Field.yearly.mean.1, "Field")
  expect_is(GUESS.Field.yearly.mean.2, "Field")
  expect_is(GUESS.Field.spatial.mean.1, "Field")
  expect_is(GUESS.Field.spatial.mean.2, "Field")
  
  # check the results are the same
  expect_identical(GUESS.Field.monthly.mean.1 ,  GUESS.Field.monthly.mean.2)
  expect_identical(GUESS.Field.yearly.mean.1 ,  GUESS.Field.yearly.mean.2)
  expect_identical(GUESS.Field.spatial.mean.1 ,  GUESS.Field.spatial.mean.2)
  expect_identical(GUESS.Field.seasonal.mean.1 ,  GUESS.Field.seasonal.mean.2)
 
  
  
})


### SELECTIONS
context("Selections and Cropping")

# years
GUESS.Field.selected.years.1 <- getField(GUESS.Europe.test.Source, "mlai", first.year = 2001, last.year = 2005)
GUESS.Field.selected.years.2 <- selectYears(x = GUESS.mlai.Field.full, first = 2001, last = 2005)

# months (not available in getField but test by numbers and abbreviation)
GUESS.Field.selected.months.1 <- selectMonths(x = GUESS.mlai.Field.full, months = c(1,4,12) )
GUESS.Field.selected.months.2 <- selectMonths(x = GUESS.mlai.Field.full, months = c("Jan","Apr","Dec") )

# days (not available in test data)

# seasons (not available in getField)
GUESS.Field.selected.seasons.1 <- selectSeasons(x = GUESS.Field.seasonal.mean.1, seasons = c("JJA", "SON") )

# single gridcell
test.gridcell <- c(16.25, 58.75)
GUESS.Field.selected.gridcell.1 <- getField(GUESS.Europe.test.Source, "mlai", spatial.extent = test.gridcell, spatial.extent.id = "TestGridcell")
GUESS.Field.selected.gridcell.2 <- selectGridcells(x = GUESS.mlai.Field.full, gridcells = test.gridcell, spatial.extent.id = "TestGridcell")

# by a data.frame
test.gridcells.df <- data.frame("Lon" = c(16.25, 7.25, 3.75), "Lat" = c(58.75, 49.25, 50.75))
GUESS.Field.selected.gridcells.df.1 <- getField(GUESS.Europe.test.Source, "mlai", spatial.extent = test.gridcells.df, spatial.extent.id = "TestGridcellsDF")
GUESS.Field.selected.gridcells.df.2 <- selectGridcells(x = GUESS.mlai.Field.full, gridcells = test.gridcells.df, spatial.extent.id = "TestGridcellsDF")

# by a data.table
test.gridcells.dt <- data.table("Lon" = c(16.25, 7.25, 3.75), "Lat" = c(58.75, 49.25, 50.75))
GUESS.Field.selected.gridcells.dt.1 <- getField(GUESS.Europe.test.Source, "mlai", spatial.extent = test.gridcells.dt, spatial.extent.id = "TestGridcellsDT")
GUESS.Field.selected.gridcells.dt.2 <- selectGridcells(x = GUESS.mlai.Field.full, gridcells = test.gridcells.dt, spatial.extent.id = "TestGridcellsDT")

# by a polygon?
# - not sure, maybe pull something from the maps package

# crop by a raster
test.raster <- raster::raster(ymn=48, ymx=59, xmn=4, xmx=17, resolution = 0.5, vals=0)
GUESS.Field.selected.raster.1 <- getField(GUESS.Europe.test.Source, "mlai", spatial.extent = test.raster, spatial.extent.id = "TestExtent")
GUESS.Field.selected.raster.2 <- crop(x = GUESS.mlai.Field.full, y = test.raster, spatial.extent.id = "TestExtent")

# crop by an extent 
test.extent <- extent(test.raster)
GUESS.Field.selected.extent.1 <- getField(GUESS.Europe.test.Source, "mlai", spatial.extent = test.extent, spatial.extent.id = "TestExtent")
GUESS.Field.selected.extent.2 <- crop(x = GUESS.mlai.Field.full, y = test.extent, spatial.extent.id = "TestExtent")

# crop by another Field 
GUESS.Field.selected.Field.1 <- getField(GUESS.Europe.test.Source, "mlai", spatial.extent = GUESS.Field.selected.extent.1, spatial.extent.id = "TestExtent")
GUESS.Field.selected.Field.2 <- crop(x = GUESS.mlai.Field.full, y = GUESS.Field.selected.extent.1, spatial.extent.id = "TestExtent")




# test aggregations
test_that("Aggregation",{
  
  # check they give Fields
  expect_is(GUESS.Field.selected.years.1, "Field")
  expect_is(GUESS.Field.selected.years.2, "Field")
  expect_is(GUESS.Field.selected.months.1, "Field")
  expect_is(GUESS.Field.selected.months.2, "Field")
  expect_is(GUESS.Field.selected.seasons.1, "Field")
  expect_is(GUESS.Field.selected.gridcell.1, "Field")
  expect_is(GUESS.Field.selected.gridcell.2, "Field")
  expect_is(GUESS.Field.selected.gridcells.df.1, "Field")
  expect_is(GUESS.Field.selected.gridcells.df.2, "Field")
  expect_is(GUESS.Field.selected.gridcells.dt.1, "Field")
  expect_is(GUESS.Field.selected.gridcells.dt.2, "Field")
  expect_is(GUESS.Field.selected.raster.1, "Field")
  expect_is(GUESS.Field.selected.raster.2, "Field")
  expect_is(GUESS.Field.selected.extent.1, "Field")
  expect_is(GUESS.Field.selected.extent.2, "Field")
  expect_is(GUESS.Field.selected.Field.1, "Field")
  expect_is(GUESS.Field.selected.Field.2, "Field")
  
 
  # check the results are the same by two different routes
 
  expect_identical(GUESS.Field.selected.years.1,  GUESS.Field.selected.years.2)
  expect_identical(GUESS.Field.selected.months.1 ,  GUESS.Field.selected.months.2)
  expect_identical(GUESS.Field.selected.gridcell.1 ,  GUESS.Field.selected.gridcell.2)
  expect_identical(GUESS.Field.selected.gridcells.df.1,  GUESS.Field.selected.gridcells.df.2)
  expect_identical(GUESS.Field.selected.gridcells.dt.1,  GUESS.Field.selected.gridcells.dt.2)
  expect_identical(GUESS.Field.selected.raster.1,  GUESS.Field.selected.raster.2)
  expect_identical(GUESS.Field.selected.extent.1,  GUESS.Field.selected.extent.2)
  expect_identical(GUESS.Field.selected.Field.1,  GUESS.Field.selected.Field.2)
  expect_identical(GUESS.Field.selected.extent.1,  GUESS.Field.selected.Field.1)
  expect_identical(GUESS.Field.selected.raster.1,  GUESS.Field.selected.Field.1)

})




### PLOTTING - expand these to test more plotting options
context("Plotting")


test_that("Plotting", {
  
  # spatial plotting
  expect_is(plotSpatial(GUESS.Field.monthly.mean.1), "ggplot")
  expect_is(plotSpatial(GUESS.Field.yearly.mean.1), "ggplot")
  expect_is(plotSpatial(Biomes.Field.full), "ggplot")
  expect_is(plotSpatial(Saatchi.Field.full), "ggplot")
  
  # test plot options?

  # temporal plotting
  expect_is(plotTemporal(GUESS.Field.spatial.mean.1), "ggplot")
  
  # seaconal cycle plotting -- update after plotSeasonal rebuilt
  #expect_is(plotSeasonal(GUESS.Field.spatial.mean.1), "ggplot")
  
 
})





### NUMERIC COMPARISONS AND BENCHMARKING
context("Numeric Comparisons and Benchmarks")

test_that("Numeric Comparisons and Benchmarks", {
  
  # build and test a numeric Comparison
  GUESS.Field.vegC_std.annual <- aggregateYears(GUESS.vegC_std.Field.full, "mean")
  GUESS.Field.vegC_std.annual <- layerOp(GUESS.Field.vegC_std.annual, "+", ".Tree", "Tree")
  expect_is(GUESS.Field.vegC_std.annual, "Field")
  Saatchi.comparison <- compareLayers(GUESS.Field.vegC_std.annual, Saatchi.Field.full, layers1 = "Tree", verbose = FALSE, show.stats = FALSE)
  expect_is(Saatchi.comparison, "Comparison")
  
  # plot said numeric Comparison
  expect_is(plotSpatialComparison(Saatchi.comparison), "ggplot")
  expect_is(plotSpatialComparison(Saatchi.comparison, type = "difference"), "ggplot")
  expect_is(plotSpatialComparison(Saatchi.comparison, type = "percentage.difference"), "ggplot")
  expect_is(plotSpatialComparison(Saatchi.comparison, type = "values"), "ggplot")
  # expect_is(plotSpatialComparison(Saatchi.comparison, type = "nme"), "ggplot")
  
  
})

### CATEGORICAL QUANTITIES
context("Categorical Quantities")

# biomes
# Note: Known and deliberate warning when calculating biomes, suppress for clarity in results
GUESS.Smith2014.Biomes <- suppressWarnings(getBiomes(source = GUESS.Europe.test.Source, scheme = Smith2014BiomeScheme, year.aggregate.method = "mean"))

# max PFT
GUESS.Field.lai.annual <- aggregateYears(GUESS.lai.Field.full, "mean")
GUESS.Field.lai.annual <- layerOp(GUESS.Field.lai.annual, operator = "max.layer", ".PFTs", "MaxPFT")


test_that("Categorical Quantities", {
  
  expect_is(GUESS.Smith2014.Biomes, "Field")
  expect_is(GUESS.Field.lai.annual, "Field")
  
  expect_is(plotSpatial(GUESS.Smith2014.Biomes), "ggplot")
  expect_is(plotSpatial(GUESS.Field.lai.annual, layer = "MaxPFT"), "ggplot")
  
})


### CATEGORIAL COMPARISONS AND BENCHMARKING
context("Categorical Comparisons and Benchmarks")

test_that("Categorical Comparisons and Benchmarks", {
  
  # build and test a categroal Comparison
  Biomes.comparison <- compareLayers(GUESS.Smith2014.Biomes, Biomes.Field.full, layers1 = "Smith2014", verbose = FALSE, show.stats = FALSE)
  expect_is(Biomes.comparison, "Comparison")
  
  # plot said numeric Comparison
  expect_is(plotSpatialComparison(Biomes.comparison), "ggplot")
  expect_is(plotSpatialComparison(Biomes.comparison, type = "difference"), "ggplot")
  expect_warning(plotSpatialComparison(Biomes.comparison, type = "percentage.difference"))
  expect_is(plotSpatialComparison(Biomes.comparison, type = "values"), "ggplot")
  # expect_is(plotSpatialComparison(Saatchi.comparison, type = "nme"), "ggplot")
  
  
})



###  EXPORTING

