#!/usr/bin/python

import sys

# argument 1 is the log file to read
target_log = sys.argv[1]

# argument 2 is the output file
output_log = sys.argv[2]

# all the rest of the arguments are usernames ( [3:] returns all indicies 3 and after )
user_names = sys.argv[3:]

# initialize variables
output = []
lineno = 1;

# open input file and iterate over lines
file = open(target_log, 'r')
for line in file:
    # check the line for each username
    for user_name in user_names:
        if user_name in line:
            # append to the output in a csv-ish format
            output.append('"' + user_name + '","' + str(lineno) + '","' + line[:-1] + '"\n')
    lineno = lineno + 1

# close the input file
file.close()

# open the output file and write contents, then close
file = open(output_log, 'a')
for line in output:
    file.write(line)

file.close()

