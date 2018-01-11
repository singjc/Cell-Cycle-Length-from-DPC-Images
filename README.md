# Growth Rate and Cell Cycle Length Analysis

The following document describes how to utilize the Growth Rate workflow.

## Plate Map Excel File
The following details information on how to use and fill out the Plate Map Excel file.
1.	Sheet “PlateMap”
*	This sheet is reserved for your 96-well plate map design; in the 60-cells (clear coloured cells), enter your treatment type for each specific well. I.e Well 1 = cell B2 = LKB1 KnockDown + 75nM Radicicol.
2.	Sheet “Drugs”
*	This sheet is reserved for any Drug treatments used in your experiment. Enter the drug name under column header ‘drug’ and enter the corresponding type, being a ‘Control’ or ‘Treatment’.
3.	Sheet “Timepoints”
*	This sheet is used to keep track of the dates and times of DPC measurements; to calculate each time point.
4.	Sheet “Conc.”
*	This sheet is used calculate and prepare drug concentrations.
5.	Sheet ‘To Print”
*	This sheet is used to print experimental plate map and drug concentration table

## Dataset Excel File
The following details information on how to use and fill out the Dataset  Excel file.
1.	Sheet “Data”
*	Field Header “Path to Dataset”
**	Enter the full path to the location of the folder containing your ResultsTable Data. 
**	i.e. \\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Processed OutPutFiles\Dataset_20171204_JS_cycE_6HrRESULTS
*	Field Header “Plate_Map”
**	Enter the full path to the location of the folder containing your Plate Map Excel File.
**	i.e. \\carbon.research.sickkids.ca\rkafri\Justin S\Experiments\Growth Rate\Plate map 20171204_cycE1.xlsx
*	Field Header “Sheet”:
**	Enter the sheet name that contains your experimental platemap. i.e. PlateMap
*	Field Header “Range”
**	Enter the cell range that contains your 60-well experimental information. i.e. B2:K7
*	Field Header “Sheet2”
**	Enter the sheet name that contains all the names of the drugs used in your experiment. i.e. Drugs
*	Field Header “Exp_Name”
**	Enter a unique experiment name for each unique experiment. i.e. 20171204_JS_cycE.
*	Field Header “Time-Point”
**	Enter the corresponding time point to the corresponding ResultsTable dataset.
*	Field Header “Cell Line”
**	Enter the cell line for each corresponding dataset. i.e. RPE1
*	Field Header “Expression”
**	If your cell lines are specific inducible cell lines, enter the specific type of inducible expression. i.e. cycE. 
**	You can enter more than one, but they must be separated by a comma (,). i.e. cycE,cycD,p27
**	In your case, you could put LKB1neg or LKB1pos.
*	Field Header “Imaging_Type”
**	Enter the type of imaging measurement, either DPC or SE.
*	Field Header “Date”
**	Enter the date of experiment.
2.	Sheet “MasterSheet”
*	Don’t worry about this sheet.
