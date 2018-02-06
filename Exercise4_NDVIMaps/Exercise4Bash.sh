echo "Team: Chantalle_Tom"
echo "Names: Chantalle Diepmaat & Tom Hardy"
echo "Date: 11 January 2018"
echo "Make a local copy of the original tif file."
cp Data/LE71700552001036SGS00_SR_Gewata_INT1U.tif Data/input.tif
echo "Calculate the NDVI based on the input file."
gdal_calc.py -A Data/input.tif --A_band=4 -B Data/input.tif --B_band=3  --outfile=Data/NDVI.tif  --calc="(A.astype(float)-B)/(A.astype(float)+B)" --type='Float32'
echo "Remove the input file."
rm Data/input.tif
echo "Resample the NDVI tif file to pixels of 60m."
gdalwarp -tr 60 60 Data/NDVI.tif Data/NDVI6060.tif
echo "Reproject the resampled file according to the datum EPSG:4326"
gdalwarp -t_srs '+proj=longlat +ellps=WGS84 +datum=WGS84' Data/NDVI6060.tif Data/NDVI_WGS84.tif
