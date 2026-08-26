# Downloads ESACCI soil moisture data from formatted JSON files.
# Expects file names in the format "esacci_sm_v{version_number}_{year}.json"
# Automatically handles adding biweek number to each downloaded file's name.
# Last Updated: 08/17/2026
# Author(s): Gabriel Laboy (@glaboy-vol)

###############
### IMPORTS ###
###############

from pathlib import Path
import argparse
import requests
import json
import os

#################
### FUNCTIONS ###
#################

def download_esacci_daily_sm(date_range, json_folder, output_folder):
    """
    Download ESA CCI daily soil moisture files.

    Download files from locally stored JSON files containing download 
    URLS to ESACCI daily soil moisture values within a specified date
    range.

    Parameters
    ----------
    date_range : tuple(int)
        The start and end year to download data for. Format is (YYYY, YYYY).
    json_folder : str
        Name or path to a folder containing ESACCI json files.
    output_folder : str
        Name or path to a folder to store downloaded files.
    """

    try:
        # Extract year range from date range
        years = list(range(date_range[0], date_range[1] + 1))

        # Get download URLs of daily soil moisture for each year
        download_urls = []
        for year in years:
            # Open JSON
            json_file = os.path.join(json_folder, f"esacci_sm_v9.2_{year}.json")
            with open(json_file, "r") as f:
                json_data = json.load(f)

            # Get download URLs, ensuring to filter only URLs within date range
            download_urls = [item["download"] for item in json_data["items"]]

            # Create the ouptut folder if not already done so
            year_folder = os.path.join(output_folder, str(year))
            Path(year_folder).mkdir(parents=True, exist_ok=True)

            biweek = 1
            counter = 0
            for url in download_urls:
                # If file already exists, skip
                output_file = os.path.join(year_folder, f"biweek_{biweek:02d}_{url.split("/")[-1].split("?")[0]}")
                if os.path.exists(output_file):
                    counter = counter + 1
                    if (counter >= 16):
                        biweek = biweek + 1
                        counter = 0
                    continue
            
                with requests.get(url, stream=True) as response:
                    response.raise_for_status()  # Raise an HTTPError for bad responses
                    with open(output_file, "wb") as f:
                        for chunk in response.iter_content(chunk_size=8192):
                            f.write(chunk)

                counter = counter + 1
                if (counter >= 16):
                    # Increment biweek
                    biweek = biweek + 1
                    counter = 0
    except requests.exceptions.RequestException as e:
        print(f"Error downloading files: {e}")      
        return 
    

############
### MAIN ###
############

# Get command line arguments
parser = argparse.ArgumentParser(description="Arguments for ESACCI data download.")
parser.add_argument("-sy", "--start-year", help="First year of ESACCI data to download.", default=2002)
parser.add_argument("-ey", "--end-year", help="Last year of ESACCI data to download.", default=2024)
parser.add_argument("-jd", "--json-directory", help="Directory with formatted ESACCI JSONs.", default="./")
parser.add_argument("-od", "--out-directory", help="Storage directory for downloaded data.", default="./")
args = parser.parse_args()

# Download ESA CCI soil moisture data
download_esacci_daily_sm((int(args.start_year), int(args.end_year)), args.json_directory, args.out_directory)
