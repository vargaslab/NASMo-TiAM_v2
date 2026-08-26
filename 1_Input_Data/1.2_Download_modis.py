# Downloads data from NASA Earthdata using the earthaccess API.
# Only tested to work with MODIS datasets.
# Last Updated: 08/17/2026
# Author(s): Gabriel Laboy (@glaboy-vol)

###############
### IMPORTS ###
###############

import earthaccess
import argparse
import os

#################
### CONSTANTS ###
#################

NA_BOUNDING_BOX = (-179.5000, 12.0000, -50.0000, 86.0000)

NA_MODIS_REGIONS = ["h07v03", "h07v04", "h07v05", "h07v06", "h07v07", "h08v02", "h08v03", "h08v04", "h08v05",
                    "h08v06", "h08v07", "h09v02", "h09v03", "h09v04", "h09v05", "h09v06", "h09v07", "h10v02",
                    "h10v03", "h10v04", "h10v05", "h10v06", "h10v07", "h11v01", "h11v02", "h11v03", "h11v04",
                    "h11v05", "h11v06", "h11v07", "h12v02", "h12v03", "h12v04", "h12v05", "h13v01", "h13v02",
                    "h13v03", "h13v04", "h13v05", "h14v00", "h14v01", "h14v02", "h14v03", "h14v04", "h14v05",
                    "h15v00", "h15v01", "h15v02", "h15v03", "h16v00", "h16v01", "h17v00"]

#################
### FUNCTIONS ###
#################

def download_earthdata_dataset(dataset, bounding_box, date_range, output_folder, regions=None, version=None, extension=None):
    """
    Download MODIS data for North America from NASA Earthdata.

    Download MODIS data from the NASA Earthdata repository using their Python API.
    This function is designed to capture specific tiles within North America.
    Note that an Earthdata account is needed in order to download this data,
    and you will be prompted for login on running the function.

    Parameters
    ----------
    dataset : str
        A short-name version of a valid Earthdata dataset.
    bounding_box : tuple
        The coordinate extents to find data for. 
        Format is (left_lon, bottom_lat, right_lon, top_lat).
    date_range : tuple(str)
        The date range to download data for.
        Format is (YYYY-mm-dd, YYYY-mm-dd).
    output_folder : str
        Name or path to an output folder to store downloaded files.
    regions : List[str], optional
            A list of region codes to filter downloaded to (default is None).
    version : str, optional
        The version of the dataset to download (default is None).
        If none given, latest version of dataset is downloaded.
    extension : str, optional
        The extension of the files to download (default is None).
    """

    try:
        # Login with Earthdata account
        earthaccess.login()

        # Search for valid data using set parameters
        results = earthaccess.search_data(
            short_name = dataset,
            version = version,
            bounding_box = bounding_box,
            temporal = date_range
        )

        # Gather only download URLs from search results
        urls = []
        for result in results:
            urls.extend(result.data_links())

        # Filter URLs to only be ones within valid regions
        filtered_urls = []
        if regions is not None:
            for url in urls:
                if any(region in url for region in regions):
                    filtered_urls.append(url)
        else:
            filtered_urls = urls

        # If an extension specified, filter download URLs to only get files with desired extension
        if extension is not None:
            filtered_urls = [url for url in filtered_urls if url.rstrip().endswith(extension)]

        if not filtered_urls:
            print(f"No data found for {dataset}.")
            return

        # Download files by year
        start_year = date_range[0][0:4]
        end_year = date_range[1][0:4]
        years = list(range(int(start_year), int(end_year)+1))
        for year in years:
            year_urls = [url for url in filtered_urls if ("A"+str(year) in url)]
            files = earthaccess.download(year_urls, os.path.join(output_folder,str(year)))
    except Exception as e:
        print(f"Error downloading data from Earthdata: {e}")
        return
    

############
### MAIN ###
############

parser = argparse.ArgumentParser(description="Arguments for downloading MODIS data.")
parser.add_argument("-ds", "--dataset", help="The code for the MODIS data to download.")
parser.add_argument("-bb", "--bounding-box", help="The bounding box covering the area to download files for.", default=NA_BOUNDING_BOX)
parser.add_argument("-r", "--regions", help="A list of region tile codes to help filter downloaded files.", default=NA_MODIS_REGIONS)
parser.add_argument("-sd", "--start-date", help="The start date to get data for.", default="2002-01-01")
parser.add_argument("-ed", "--end-date", help="The end date to get data for.", default="2024-12-31")
parser.add_argument("-d", "--directory", help="Directory where the downloaded MODIS data will be stored.", default="./")
parser.add_argument("-v", "--version", help="The version of the MODIS to download.", default=None)
parser.add_argument("-e", "--extension", help="The file extension of files to download.", default=None)
args = parser.parse_args()

download_earthdata_dataset(args.dataset, args.bounding_box, (args.start_date, args.end_date), args.directory, args.regions, args.version, args.extension)
