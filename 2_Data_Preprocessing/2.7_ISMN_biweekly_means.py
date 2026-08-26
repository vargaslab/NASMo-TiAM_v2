import pandas as pd
import numpy as np
import argparse
import datetime
import os

### CONSTANTS ###

GOOD_DATA_CODE = "G"
ISMN_FILE_EXTENSION = ".stm"

### FUNCTIONS ###

def get_ismn_files(data_directory):
    """
    Get a list of all ISMN files.

    Recursively searches a specified directory to find all valid
    ISMN files containing soil moisture data. Valid ISMN files
    should end with the extension `.stm`.
    
    Parameters
    ----------
    data_directory : str
        The directory to search for valid ISMN files in.

    Returns
    -------
    List[str]
        The list of valid ISMN files found.
    """

    # Recursively walk through specified directory to find all valid ISMN files
    file_list = []
    for root, dirs, files in os.walk(data_directory):
        for filename in files:
            if ISMN_FILE_EXTENSION in filename:
                full_path = os.path.join(root, filename)
                file_list.append(full_path)

    return file_list


def format_valid_sm_data(file_list, out_csv):
    """
    Format ISMN data into a dataframe.

    Formats ISMN soil moisture data into a dateframe and
    preserves into on the project, station, lat and lon coordinates,
    the datetime of collection, and the soil moisture value.

    Parameters
    ----------
    file_list : List[str]
        The list of ISMN files.
    out_csv : str
        A path to a CSV file to store formatted ISMN results to.

    Returns
    -------
    pandas Dataframe
        A pandas dataframe with formatted ISMN data.
    """

    # Get valid soil moisture data from each file
    data_list = []
    for file in file_list:
        dataset, station, lat, lon = "", "", "", ""
        with open(file, 'r') as f:
            for i, line in enumerate(f):
                entry = line.strip().split()
                if i == 0:
                    # If first row, extract important metadata
                    dataset = entry[0]
                    station = entry[2]
                    lat = entry[3]
                    lon = entry[4]
                elif ((entry[3] == GOOD_DATA_CODE) or (entry[4] == GOOD_DATA_CODE)):
                    # Add new line of data to list
                    formatted_date = entry[0].replace("/", "-") + "-" + entry[1] + ":00"
                    new_entry = [dataset, station, lat, lon, formatted_date, entry[2]]
                    data_list.append(new_entry)

    # Convert data to a dataframe and return
    df = pd.DataFrame(data_list, columns=["Dataset_Name", "Station_ID", "Latitude", "Longitude", "Date", "mean_sm_depth_5cm"])
    df.to_csv(out_csv, index=True)
    return df


def get_biweekly_sm_means(sm_df, out_csv, stats = False):
    """
    Computes monthly soil moisture means of table-formatted ISMN data.

    Computes the monthly soil moisture means of table-formatted data from
    the ISMN. Final data preserved are unique lat and lon coordinates,
    the year and month of the mean, and the mean'd soil moisture value.

    Parameters
    ----------
    sm_df : pandas Dataframe
        An appropiately formatted dataframe with ISMN soil moisture data.
    out_csv : str
        A path to a CSV file to store mean soil moisture results.
    stats : bool, optional
        Print optional stats on soil moisture mean results (default is False).
    """

    # Create temporary columns containing only year and biweek of each row
    sm_df["Date"] = pd.to_datetime(sm_df["Date"], format="%Y-%m-%d-%H:%M:%S")
    sm_df["Year"] = sm_df["Date"].dt.year
    sm_df["Biweek"] = sm_df["Date"].dt.dayofyear / 16
    sm_df["Biweek"] = np.ceil(sm_df["Biweek"])

    # Convert sm column to type float
    sm_df["mean_sm_depth_5cm"] = sm_df["mean_sm_depth_5cm"].astype(float)

    # Round latitude and longitude
    sm_df["Latitude"] = sm_df["Latitude"].round(2)
    sm_df["Longitude"] = sm_df["Longitude"].round(2)
    
    # Compute mean of soil moisture grouping by month and unique coordinates
    sm_means = sm_df.groupby(["Station_ID", "Latitude", "Longitude", "Year", "Biweek"])["mean_sm_depth_5cm"].mean()

    if stats:
        print("Number of unique coordinates: ", len(sm_df[["Latitude", "Longitude"]].drop_duplicates()))
        print("\nNumber of unique soil moisture means by coordinate:")
        print(sm_means.groupby(["Latitude", "Longitude"]).size().to_string())

    # Save to CSV
    sm_means.to_csv(out_csv, index=True)


def split_biweekly_sm_means(in_csv, out_dir):
    """
    Split a CSV with biweekly means to numerous CSVs organized by biweek.

    Takes a CSV with biweekly soil moisture means over numerous
    """

    # Read from input csv
    df = pd.read_csv(in_csv)
    years = sorted(df["Year"].unique())
    biweeks = sorted(df["Biweek"].unique())

    for year in years:
        for biweek in biweeks:
            # Extract only data for a single biweek
            biweekly_mean = df.loc[(df["Year"] == year) & (df["Biweek"] == biweek)]

            # Save biweek data to CSV
            out_file = os.path.join(out_dir, f"ismn_biweekly_mean_sm_{year}_{biweek:02d}.csv")
            biweekly_mean.to_csv(out_file, index=True)


### MAIN ###

if __name__ == "__main__":
    # Get command line arguments
    parser = argparse.ArgumentParser(description="Arguments for processing a collection of ISMN data.")
    parser.add_argument("-d", "--data", help="Directory containing all STM files from ISMN", default="./0_Input_data/7_ISMN_validation/1_ismn_reading_files")
    parser.add_argument("-t", "--tablecsv", help="Output CSV to store valid ISMN soil moisture entries", default="./1_Preprocessed_data/7_ISMN_validation/1_ismn_northamerica_selected_stations/ismn_all_valid_sm_entries.csv")
    parser.add_argument("-o", "--outcsv", help="Output CSV to store biweekly soil moisture mean results", default="./1_Preprocessed_data/7_ISMN_validation/2_ismn_stations_biweekly_means/ismn_all_biweekly_means.csv")
    parser.add_argument("-od", "--outdir", help="Output directory for all biweekly CSVs to be stored in", default="./1_Preprocessed_data/7_ISMN_validation/3_ismn_biweekly_means_northamerica")
    parser.add_argument("-v", "--verbose", help="Adds extra output for analysis", default=False)
    args = parser.parse_args()

    # Get all ISMN files with soil moisture data
    ismn_files = get_ismn_files(args.data)

    # Format all valid ISMN soil moisture values into a table
    sm_data = format_valid_sm_data(ismn_files, args.tablecsv)

    # Get monthly means of soil moisture for each unique coordinate and save to CSV
    get_biweekly_sm_means(sm_data, args.outcsv, args.verbose)

    # Split all biweekly sm estimates into their own year and biweek files
    split_biweekly_sm_means(args.outcsv, args.outdir)
