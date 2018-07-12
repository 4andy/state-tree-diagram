# Get SDE state and version data

import arcpy
from pandas import DataFrame
import tempfile
import os

sdefile = arcpy.GetParameterAsText(0)

# set temp file path
tmpdir = tempfile.mkdtemp(prefix='StateDiagram_')
arcpy.SetParameterAsText(1, tmpdir)

arcpy.AddMessage("Saving temporary files to")
arcpy.AddMessage(tmpdir)

# get DBMS info
instance = arcpy.Describe(sdefile).connectionProperties.instance

# set column names
columns = ['parent', 'vertex', 'version', 'lineage']

# open database connection
con = arcpy.ArcSDESQLExecute(sdefile)

# run query depending on DBMS
try:
    # Oracle table names are different
    if "sde:oracle" in instance:
        sql = ("""SELECT parent_state_id
               , states.state_id
               , name AS version
               , lineage_name
               FROM sde.states LEFT JOIN sde.versions
               ON states.state_id = versions.state_id
               ORDER BY states.state_id""")
        data = DataFrame(con.execute(sql), columns=columns)
    else:
        try:
            sql = ("""SELECT parent_state_id
                      , sde_states.state_id
                      , name AS version
                      , lineage_name
                      FROM sde.sde_states LEFT JOIN sde.sde_versions
                      ON sde_states.state_id = sde_versions.state_id
                      ORDER BY sde_states.state_id;""")
            data = DataFrame(con.execute(sql), columns=columns)
        except AttributeError:
            # try dbo schema if above failed
            sql = ("""SELECT parent_state_id
                      , sde_states.state_id
                      , name AS version
                      , lineage_name
                      FROM dbo.sde_states LEFT JOIN dbo.sde_versions
                      ON sde_states.state_id = sde_versions.state_id
                      ORDER BY sde_states.state_id;""")
            data = DataFrame(con.execute(sql), columns=columns)
except AttributeError as err:
    arcpy.AddError("Unable to access database version tables." +
                   "\nMake sure connection has database administrator" +
                   "\ncredentials and see error below.")
    raise err

# save csv file with data
data.to_csv(tmpdir + os.sep + "data.csv", index=False)
