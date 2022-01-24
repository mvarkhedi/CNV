import csv
import os

casefile = 'NBLsample.tsv'
with open(casefile) as case_file:
    casefile_reader = csv.reader(case_file, delimiter='\t')
    casedict = {}
    for row in casefile_reader:
        if 'Blood Derived Normal' in row[7]:
              command = 'cp sliced_' + row[1] + ' ' +  row[5] + '_BLOOD_' + 'wxs'
              print('echo "Running ' + command + '"') 
              print(command)
        if 'Primary Tumor'  in row[7]:
              command = 'cp sliced_' + row[1] + ' ' +  row[5] + '_TUMOR_' + 'wxs'
              print('echo "Running ' + command + '"') 
              print(command)
