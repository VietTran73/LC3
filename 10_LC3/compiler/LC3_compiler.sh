#!/bin/bash

start_code=12288
opCode=0
drID=0
sr1ID=0
sr2ID=0
imm=0

rm app.mem
touch app.mem

for ((i=0;i<$start_code;i++)); do
	echo "0000000000000000" >> app.mem
done

while IFS= read -r line; do
	IFS=' ' read -r -a array <<< "$line"
#	echo "element 0: ${array[0]}"
#	echo "element 1: ${array[1]}"
#	echo "element 2: ${array[2]}"
#	echo "element 3: ${array[3]}"

	if   [[ ${array[0]} == *"ADD"* ]]; then opCode="0001"
	elif [[ ${array[0]} == *"AND"* ]]; then opCode="0101"
	elif [[ ${array[0]} == *"NOT"* ]]; then opCode="1001"
	fi

	if [[ ${array[1]} == *"R0"* ]]; then drID="000"
	elif [[ ${array[1]} == *"R1"* ]]; then drID="001"
	elif [[ ${array[1]} == *"R2"* ]]; then drID="010"
	elif [[ ${array[1]} == *"R3"* ]]; then drID="011"
	elif [[ ${array[1]} == *"R4"* ]]; then drID="100"
	elif [[ ${array[1]} == *"R5"* ]]; then drID="101"
	elif [[ ${array[1]} == *"R6"* ]]; then drID="110"
	elif [[ ${array[1]} == *"R7"* ]]; then drID="111"
	fi

        if   [[ ${array[2]} == *"R0"* ]]; then sr1ID="000"
        elif [[ ${array[2]} == *"R1"* ]]; then sr1ID="001"
        elif [[ ${array[2]} == *"R2"* ]]; then sr1ID="010"
        elif [[ ${array[2]} == *"R3"* ]]; then sr1ID="011"
        elif [[ ${array[2]} == *"R4"* ]]; then sr1ID="100"
        elif [[ ${array[2]} == *"R5"* ]]; then sr1ID="101"
        elif [[ ${array[2]} == *"R6"* ]]; then sr1ID="110"
        elif [[ ${array[2]} == *"R7"* ]]; then sr1ID="111"
        fi

        if   [[ ${array[3]} == *"R0"* ]]; then sr2ID="000"
        elif [[ ${array[3]} == *"R1"* ]]; then sr2ID="001"
        elif [[ ${array[3]} == *"R2"* ]]; then sr2ID="010"
        elif [[ ${array[3]} == *"R3"* ]]; then sr2ID="011"
        elif [[ ${array[3]} == *"R4"* ]]; then sr2ID="100"
        elif [[ ${array[3]} == *"R5"* ]]; then sr2ID="101"
        elif [[ ${array[3]} == *"R6"* ]]; then sr2ID="110"
        elif [[ ${array[3]} == *"R7"* ]]; then sr2ID="111"
        fi

        IFS='#' read -r -a number <<< "${array[3]}"
        number_bin=$(echo "obase=2;${number[1]}" | bc)
	if    [[ ${#number_bin} == 1 ]]; then number_bin="0000$number_bin"
	elif  [[ ${#number_bin} == 2 ]]; then number_bin="000$number_bin"
	elif  [[ ${#number_bin} == 3 ]]; then number_bin="00$number_bin"
	elif  [[ ${#number_bin} == 4 ]]; then number_bin="0$number_bin"
	fi

	if [[ $line != *"ORIG"* ]]; then
		if [[ $line == "HALT" ]]; then
			binary_code="1111000000100101"
		elif [[ $line == *"NOT"* ]]; then
			binary_code="${opCode}${drID}${sr1ID}111111"
		elif [[ ${array[3]} == *"#"* ]]; then
			binary_code="${opCode}${drID}${sr1ID}1${number_bin}"
		else
			binary_code="${opCode}${drID}${sr1ID}000${sr2ID}"
		fi
		echo $binary_code >> app.mem
	fi

done < app.txt


