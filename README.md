## checkpoint_hit_count_extractor

It's a Bash script that extracts the hit count of rules in a specific policy package of a Checkpoint firewall. This is script is tested on R80+ and R81+ series GAIA OS.

![image](https://user-images.githubusercontent.com/75925433/222898437-29805e89-d623-40dd-aba3-ebc0d5cbf82a.png)

In this the user is prompted to enter the IP address or name of the domain or SMS (Security Management Server) they want to check.

Once the user enters the domain name or IP address, the script uses the Checkpoint API command-line interface tool "mgmt_cli" to show a list of available policy package names for that domain. The user is prompted to enter the name of the policy package they want to check.

The script then determines the size of the rulebase of the specified policy package using the "show access-rulebase" command with the "total" option. Once that is fetch it will display the total number of rules that are present on that policy package.

![image](https://user-images.githubusercontent.com/75925433/222899373-f9338f98-c762-4e71-8fdd-15cfcbb3521b.png)

> **Note:**
    *Keep in mind that sometimes we use custom name for policy package and if that is the case then after extracting available policy packages it will display name such as below,*

```
Listing all available Policy Package Names...

customname1 Network
customname2 Network
customname3 application
```
> *In such case while specifying policy package name, specify complete name like : "customname1 Network".* 
> *The script will not move ahead until you put correct policy package name.*

The user is then prompted to select one of the following options:

```
    1. All Rules
    2. Non-Zero Hit Rules
    3. Non-Zero Hit Rules with first and last hit
    4. Zero Hit Rules
```
Based on the user's selection, the script uses the "show access-rulebase" command to extract the hit count of the rules in the specified policy package. The output is saved in a CSV file named "<Policy_Package_Name>-<Today's_Date>.csv".

![image](https://github.com/IIDrGeekII/Checkpoint_hit_count_extractor/assets/75925433/251d5aa4-c1f6-4ed5-bb91-0f4c254c7dbf)

> **Note:**
    *No. of rules are mandatory to be mentioned because by default Checkpoint scan only first 500 rules. So, in order to scan more than default number or all it is required to specify number of rules.*

> *The CSV file contains 5 columns for zero hit and Non-Zero Hit Rules : **Rule_Number, Name, Hits, Traffic-level, Rule_Comment**.*

> *Also, the CSV file contains 7 columns for All Rules and Non-Zero Hit Rules with first and last hit : **Rule_Number, Name, Hits, Traffic_level, First_Hit, Last_Hit, Rule_Comment**.*

```
1. The Rule Number column contains the rule number of each rule in the policy package.
2. The Name column contains the rule name which can be used to search later in case need to check manually on Smartconsole.
3. Hits column contains the number of times each rule was hit.
4. Traffic_level column contains the level of hits each rule is having (zero,low,medium,high).
5. First_Hit column contains the date and time of first hit that the rule had on it.
6. Last_Hit column contains the date and time of recent hit that the rule had on it.
7. The Rule_Comment column contains the rule comments which can be used in case if rule name is missing to search later in case need to check manually on Smartconsole.
```

The script uses the "jq" command-line tool to parse the JSON output of the **"mgmt_cli"** command and extract the relevant information.

Here is a step-by-step guide on how to use the script:

    1. Open a terminal and navigate to the directory where you want to save the script.

    2. Use a text editor to create a new file and copy the script into the file.

    3. Save the file with a ".sh" extension (e.g., "checkpoint_hit_count_extractor.sh").

    4. Make the script executable by running the following command:
    
       chmod +x checkpoint_hit_count_extractor.sh

    5. Run the script by typing the following command:
  
      ./checkpoint_hit_count_extractor.sh
      
    6. Follow the prompts to enter the domain name or IP address of the Checkpoint firewall, 
       the name of the policy package to check, and the type of rules to extract hit counts for.

    The script will output the results to a CSV file in the same directory as the script. 
    The filename will be "<Option>-<Policy_Package_Name>-<Today's_Date_Time>.csv".

Feature Update:

```
1. Added an option to extract First and Last hit.
```

